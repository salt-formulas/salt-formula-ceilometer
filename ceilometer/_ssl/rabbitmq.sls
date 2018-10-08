{%- from "ceilometer/map.jinja" import server,agent with context %}

{%- if server.get('enabled', False) %}
  {%- set ceilometer_msg = server.message_queue %}
  {%- set ceilometer_cacert = server.cacert_file %}
  {%- set role = 'server' %}
{%- else %}
  {%- set ceilometer_msg = agent.message_queue %}
  {%- set ceilometer_cacert = agent.cacert_file %}
  {%- set role = 'agent' %}
{%- endif %}

ceilometer_ssl_rabbitmq:
  test.show_notification:
    - text: "Running ceilometer._ssl.rabbitmq"

{%- if ceilometer_msg.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=ceilometer_msg.x509.ca_file %}
  {%- set key_file=ceilometer_msg.x509.key_file %}
  {%- set cert_file=ceilometer_msg.x509.cert_file %}

rabbitmq_ceilometer_ssl_x509_ca:
  {%- if ceilometer_msg.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: ceilometer:{{ role }}:message_queue:x509:cacert
    - mode: 644
    - user: root
    - group: ceilometer
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

rabbitmq_ceilometer_client_ssl_cert:
  {%- if ceilometer_msg.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: ceilometer:{{ role }}:message_queue:x509:cert
    - mode: 640
    - user: root
    - group: ceilometer
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

rabbitmq_ceilometer_client_ssl_private_key:
  {%- if ceilometer_msg.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: ceilometer:{{ role }}:message_queue:x509:key
    - mode: 640
    - user: root
    - group: ceilometer
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

rabbitmq_ceilometer_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: root
    - group: ceilometer

{% elif ceilometer_msg.get('ssl',{}).get('enabled',False) %}
rabbitmq_ca_ceilometer:
  {%- if ceilometer_msg.ssl.cacert is defined %}
  file.managed:
    - name: {{ ceilometer_msg.ssl.cacert_file }}
    - contents_pillar: ceilometer:{{ role }}:message_queue:ssl:cacert
    - mode: 644
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ceilometer_msg.ssl.get('cacert_file', ceilometer_cacert) }}
  {%- endif %}

{%- endif %}
