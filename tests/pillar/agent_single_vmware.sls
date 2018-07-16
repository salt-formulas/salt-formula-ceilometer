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
    vmware:
      enabled: true
      host_ip: 1.2.3.4
      host_port: 443
      host_username: vmware_user
      host_password: vmware_password
