ceilometer:
  agent:
    debug: true
    #region: RegionOne
    enabled: true
    version: pike
    secret: password
    publisher:
      default:
        enabled: true
    polling:
      sources:
        odl_source:
          meters:
            - switch
            - switch.ports
            - switch.port.receive.bytes
          interval: 300
          resources:
            - opendaylight.v2://127.0.0.1:8080/controller/statistics?auth=basic&user=admin&password=unsegreto
          sinks:
            - meter_sink
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
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
