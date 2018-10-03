ceilometer:
  agent:
    polling:
      sources:
        my_pollsters:
          meters:
            - "test_meter1"
            - "regex_meters*"
          interval: 30
        all_pollsters:
          meters:
            - "*"
          interval: 100
    debug: true
    libvirt:
      ssl:
        enabled: true
      libvirt_uri: qemu://
    region: RegionOne
    enabled: true
    version: liberty
    secret: password
    publisher:
      default:
        enabled: true
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
      members:
      - host: 127.0.0.1
      - host: 127.0.0.2
      - host: 127.0.0.3
      user: openstack
      password: workshop
      virtual_host: '/openstack'
      ha_queues: true
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
