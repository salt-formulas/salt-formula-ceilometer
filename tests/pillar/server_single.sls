ceilometer:
  server:
    debug: true
    #region: RegionOne
    enabled: true
    version: mitaka
    secret: password
    ttl: 86400
    publisher:
      default:
    bind:
      host: 127.0.0.1
      port: 8777
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: ceilometer
      password: password
      endpoint_type: internalURL
    logging:
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: false
        ossyslog:
          enabled: false
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
      ha_queues: true
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
    database:
      engine: influxdb
      influxdb:
        host: 127.0.0.1
        port: 8086
        name: ceilometer
        user: ceilometer
        password: password
        database: database
      elasticsearch:
        enabled: true
        host: 127.0.0.1
        port: 8086
      policy:
        segregation: 'rule:context_is_admin'
        'telemetry:get_resource':
