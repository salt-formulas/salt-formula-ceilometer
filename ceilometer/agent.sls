{%- from "ceilometer/map.jinja" import agent with context %}
{%- if agent.enabled %}

include:
  - ceilometer._ssl.rabbitmq

ceilometer_agent_packages:
  pkg.installed:
  - names: {{ agent.pkgs }}
  - require_in:
    - sls: ceilometer._ssl.rabbitmq

ceilometer_agent_conf:
  file.managed:
  - name: /etc/ceilometer/ceilometer.conf
  - source: salt://ceilometer/files/{{ agent.version }}/ceilometer-agent.conf.{{ grains.os_family }}
  - template: jinja
  - mode: 0640
  - group: ceilometer
  - require:
    - pkg: ceilometer_agent_packages
    - sls: ceilometer._ssl.rabbitmq

{%- if agent.get('libvirt',{}).get('ssl',{}).get('enabled', False) == True %}
add_ceilometer_to_nova_group:
  user.present:
  - name: ceilometer
  - optional_groups:
    - nova
  - require:
    - pkg: ceilometer_agent_packages
{%- endif %}

{% for service_name in agent.services %}
{{ service_name }}_default:
  file.managed:
    - name: /etc/default/{{ service_name }}
    - source: salt://ceilometer/files/default
    - template: jinja
    - require:
      - pkg: ceilometer_agent_packages
    - defaults:
        service_name: {{ service_name }}
        values: {{ agent }}
    - watch_in:
      - service: ceilometer_agent_services
{% endfor %}

{% if agent.logging.log_appender -%}

{%- if agent.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
ceilometer_agent_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

{% for service_name in agent.services %}
{{ service_name }}_logging_conf:
  file.managed:
    - name: /etc/ceilometer/logging/logging-{{ service_name }}.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - mode: 0640
    - user: root
    - group: ceilometer
    - require:
      - pkg: ceilometer_agent_packages
{%- if agent.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: ceilometer_agent_fluentd_logger_package
{%- endif %}
    - makedirs: True
    - defaults:
        service_name: {{ service_name }}
        _data: {{ agent.logging }}
    - watch_in:
      - service: ceilometer_agent_services
{% endfor %}

{% endif %}

{%- for publisher_name, publisher in agent.get('publisher', {}).items() %}

{%- if agent.version in ['liberty', 'juno', 'kilo', 'mitaka', 'newton', 'ocata'] %}
{%- if publisher_name not in ['default', 'gnocchi', 'panko'] %}

ceilometer_publisher_{{ publisher_name }}_pkg:
  pkg.latest:
    - name: ceilometer-publisher-{{ publisher_name }}

{%- endif %}
{%- elif publisher.get('enabled', False) %}
{%- if publisher.pkg is defined %}

ceilometer_publisher_{{ publisher_name }}_pkg:
  pkg.latest:
    - name: {{ publisher.pkg }}

{%- endif %}
{%- endif %}

{%- endfor %}

ceilometer_agent_pipeline:
  file.managed:
  - name: /etc/ceilometer/pipeline.yaml
  - source: salt://ceilometer/files/{{ agent.version }}/pipeline.yaml
  - template: jinja
  - mode: 0640
  - group: ceilometer
  - require:
    - pkg: ceilometer_agent_packages

{%- if agent.version != 'kilo' %}

ceilometer_agent_event_pipeline:
  file.managed:
  - name: /etc/ceilometer/event_pipeline.yaml
  - source: salt://ceilometer/files/{{ agent.version }}/event_pipeline.yaml
  - template: jinja
  - mode: 0640
  - group: ceilometer
  - require:
    - pkg: ceilometer_agent_packages
  - watch_in:
    - service: ceilometer_agent_services

{%- endif %}

{# Starting Pike switch to polling.yaml to handle meters polling as recommended in upstream #}
{%- if agent.version not in ['liberty', 'juno', 'kilo', 'mitaka', 'newton', 'ocata'] and agent.polling is defined %}

ceilometer_agent_polling:
  file.managed:
  - name: /etc/ceilometer/polling.yaml
  - source: salt://ceilometer/files/{{ agent.version }}/polling.yaml
  - template: jinja
  - mode: 0640
  - group: ceilometer
  - require:
    - pkg: ceilometer_agent_packages
  - watch_in:
    - service: ceilometer_agent_services

{%- endif %}

ceilometer_agent_services:
  service.running:
  - names: {{ agent.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: ceilometer_agent_conf
    - file: ceilometer_agent_pipeline
    - sls: ceilometer._ssl.rabbitmq

{%- endif %}
