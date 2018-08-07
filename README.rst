==================
Ceilometer Formula
==================

The ceilometer project aims to deliver a unique point of contact for billing
systems to acquire all of the measurements they need to establish customer
billing, across all current OpenStack components with work underway to
support future OpenStack components.
This formula provides different backends for Ceilometer data: MongoDB, InfluxDB. Also,
Graphite and direct (to Elasticsearch) publishers are available. If InfluxDB is used
as a backend, heka is configured to consume messages from RabbitMQ and write in to
InfluxDB, i.e. ceilometer collector service is not used in this configuration.

Sample Pillars
==============

Ceilometer API/controller node
------------------------------

.. code-block:: yaml

    ceilometer:
      server:
        enabled: true
        version: mitaka
        cluster: true
        secret: pwd
        bind:
          host: 127.0.0.1
          port: 8777
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: ceilometer
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'

Enable CORS parameters
------------------------------

.. code-block:: yaml

    ceilometer:
      server:
        cors:
          allowed_origin: https:localhost.local,http:localhost.local
          expose_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_methods: GET,PUT,POST,DELETE,PATCH
          allow_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_credentials: True
          max_age: 86400


Configuration of policy.json file
---------------------------------

.. code-block:: yaml

    ceilometer:
      server:
        ....
        policy:
          segregation: 'rule:context_is_admin'
          # Add key without value to remove line from policy.json
          'telemetry:get_resource':

Databases configuration
-----------------------

MongoDB example:
~~~~~~~~~~~~~~~~

.. code-block:: yaml

    ceilometer:
      server:
        database:
          engine: mongodb
          members:
          - host: 10.0.106.10
            port: 27017
          - host: 10.0.106.20
            port: 27017
          - host: 10.0.106.30
            port: 27017
          name: ceilometer
          user: ceilometer
          password: password

InfluxDB/Elasticsearch example:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    ceilometer:
      server:
        database:
          influxdb:
            host: 10.0.106.10
            port: 8086
            user: ceilometer
            password: password
            database: ceilometer
          elasticsearch:
            enabled: true
            host: 10.0.106.10
            port: 9200

Client-side RabbitMQ HA setup
-----------------------------

.. code-block:: yaml

    ceilometer:
      server:
        ....
        message_queue:
          engine: rabbitmq
          members:
          - host: 10.0.106.10
          - host: 10.0.106.20
          - host: 10.0.106.30
          user: openstack
          password: pwd
          virtual_host: '/openstack'
       ....


Ceilometer Graphite publisher
-----------------------------

.. code-block:: yaml

    ceilometer:
      server:
        enabled: true
        publisher:
          graphite:
            enabled: true
            host: 10.0.0.1
            port: 2003

Since Pike release in order to install package for publisher, publisher definition should
have pkg field explicitly set to needed package:

.. code-block:: yaml

    ceilometer:
      server:
        enabled: true
        publisher:
          example_publisher:
            enabled: true
            url: publisher_url://
            pkg: publisher-pkg-name



Ceilometer compute agent
------------------------

.. code-block:: yaml

    ceilometer:
      agent:
        enabled: true
        version: mitaka
        secret: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: ceilometer
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
          rabbit_ha_queues: true

Ceilometer compute agent vmware:
--------------------------------

.. code-block:: yaml


    ceilometer:
      agent:
        enabled: true
        vmware:
          enabled: true
          host_ip: 1.2.3.4
          host_username: vmware_username
          host_password: vmware_password

Ceilometer instance discovery method
------------------------------------

.. code-block:: yaml

    ceilometer:
      agent:
        ...
        discovery_method: naive


Keystone auth caching
---------------------

.. code-block:: yaml

    ceilometer:
      server:
        cache:
          members:
            - host: 10.10.10.10
              port: 11211
            - host: 10.10.10.11
              port: 11211
            - host: 10.10.10.12
              port: 11211
      agent:
        cache:
          members:
            - host: 10.10.10.10
              port: 11211
            - host: 10.10.10.11
              port: 11211
            - host: 10.10.10.12
              port: 11211

Enhanced logging with logging.conf
----------------------------------

By default logging.conf is disabled.

That is possible to enable per-binary logging.conf with new variables:
  * openstack_log_appender - set it to true to enable log_config_append for all OpenStack services;
  * openstack_fluentd_handler_enabled - set to true to enable FluentHandler for all Openstack services.
  * openstack_ossyslog_handler_enabled - set to true to enable OSSysLogHandler for all Openstack services.

Only WatchedFileHandler, OSSysLogHandler and FluentHandler are available.

Also it is possible to configure this with pillar:

.. code-block:: yaml

  ceilometer:
    server:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

    agent:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

The log level might be configured per logger by using the
following pillar structure:

.. code-block:: yaml

  ceilometer:
    server:
      logging:
        loggers:
          <logger_name>:
            level: WARNING

  ceilometer:
    agent:
      logging:
        loggers:
          <logger_name>:
            level: WARNING


Enable OpenDaylight statistics driver
---------------------

.. code-block:: yaml

    ceilometer:
      server:
        opendaylight: true
        .....
      agent:
        polling:
          sources:
            odl_source:
              meters:
                - switch
                - switch.ports
                - switch.port.receive.bytes
                .....
              interval: 300
              resources:
                - opendaylight.v2://<odl-controller-ip>:8080/controller/statistics?auth=basic&user=admin&password=unsegreto
              sinks:
                - meter_sink


More Information
================

* https://wiki.openstack.org/wiki/Ceilometer
* http://docs.openstack.org/developer/ceilometer/install/manual.html
* http://docs.openstack.org/developer/ceilometer/
* https://fedoraproject.org/wiki/QA:Testcase_OpenStack_ceilometer_install
* https://github.com/spilgames/ceilometer_graphite_publisher
* http://engineering.spilgames.com/using-ceilometer-graphite/


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-ceilometer/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-ceilometer

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
