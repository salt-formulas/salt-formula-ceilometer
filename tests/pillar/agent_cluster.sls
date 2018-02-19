ceilometer:
  agent:
    region: RegionOne
    enabled: true
    version: liberty
    secret: password
    publisher:
      default:
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
        port: 5672
      - host: 127.0.0.1
        port: 5672
      - host: 127.0.0.1
        port: 5672
      user: openstack
      password: ${_param:rabbitmq_openstack_password}
      virtual_host: '/openstack'
      ha_queues: true
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
