{%- from "ceilometer/map.jinja" import server with context %}
{%- if server.enabled %}

ceilometer_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/ceilometer/ceilometer.conf:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/ceilometer-server.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages

{%- for name, rule in server.get('policy', {}).iteritems() %}

{%- if rule != None %}
rule_{{ name }}_present:
  keystone_policy.rule_present:
  - path: /etc/ceilometer/policy.json
  - name: {{ name }}
  - rule: {{ rule }}
  - require:
    - pkg: ceilometer_server_packages

{%- else %}

rule_{{ name }}_absent:
  keystone_policy.rule_absent:
  - path: /etc/ceilometer/policy.json
  - name: {{ name }}
  - require:
    - pkg: ceilometer_server_packages

{%- endif %}

{%- endfor %}

{%- for publisher_name, publisher in server.get('publisher', {}).iteritems() %}

{%- if publisher_name != "default" %}

ceilometer_publisher_{{ publisher_name }}_pkg:
  pkg.latest:
    - name: ceilometer-publisher-{{ publisher_name }}

{%- endif %}

{%- endfor %}

/etc/ceilometer/pipeline.yaml:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/pipeline.yaml
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages

{%- if server.version != "kilo" %}

/etc/ceilometer/event_pipeline.yaml:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/event_pipeline.yaml
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages
  - watch_in:
    - service: ceilometer_server_services

/etc/ceilometer/event_definitions.yaml:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/event_definitions.yaml
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages
  - watch_in:
    - service: ceilometer_server_services

/etc/ceilometer/gabbi_pipeline.yaml:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/gabbi_pipeline.yaml
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages
  - watch_in:
    - service: ceilometer_server_services

{%- endif %}

# for Ocata and newer
{%- if server.version not in ['liberty', 'juno', 'kilo', 'mitaka', 'newton'] %}

/etc/apache2/sites-available/ceilometer-api.conf:
  file.managed:
  - source: salt://ceilometer/files/{{ server.version }}/ceilometer-api.apache2.conf.Debian
  - template: jinja
  - require:
    - pkg: ceilometer_server_packages

ceilometer_api_config:
  file.symlink:
     - name: /etc/apache2/sites-enabled/ceilometer-api.conf
     - target: /etc/apache2/sites-available/ceilometer-api.conf

ceilometer_apache_restart:
  service.running:
  - enable: true
  - name: apache2
  - watch:
    - file: /etc/ceilometer/ceilometer.conf
    - file: /etc/apache2/sites-available/ceilometer-api.conf
    - file: /etc/ceilometer/event_definitions.yaml
    - file: /etc/ceilometer/event_pipeline.yaml
    - file: /etc/ceilometer/gabbi_pipeline.yaml
    - file: /etc/ceilometer/pipeline.yaml

{%- endif %}


ceilometer_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/ceilometer/ceilometer.conf

{%- endif %}
