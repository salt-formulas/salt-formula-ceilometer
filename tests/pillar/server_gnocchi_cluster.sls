ceilometer:
  server:
    debug: true
    region: RegionOne
    enabled: true
    version: pike
    cluster: true
    secret: password
    ttl: 86400
    publisher:
      default:
        enabled: false
      gnocchi:
        enabled: true
        url: gnocchi://
        publish_metric: true
        archive_policy: high
        filter_project: project
        create_resources: true
        resources_definition_file: gnocchi_resources.yaml
        request_timeout: 11.0
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
    message_queue:
      engine: rabbitmq
      members:
      - host: 127.0.0.1
      - host: 127.0.0.1
      - host: 127.0.0.1
      user: openstack
      password: password
      virtual_host: '/openstack'
      # Workaround for https://bugs.launchpad.net/ceilometer/+bug/1337715
      rpc_thread_pool_size: 5
    database:
      engine: gnocchi
