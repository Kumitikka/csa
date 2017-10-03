namespace: CSA.CloudSlang
flow:
  name: google_vm
  inputs:
    - json_token:
        default: "${get_sp('gcp_token')}"
        sensitive: false
    - proxy_host:
        default: web-proxy.bbn.hpecorp.net
        required: false
    - proxy_port:
        default: '8080'
        required: false
  workflow:
    - trim:
        do:
          io.cloudslang.base.strings.trim:
            - origin_string: "${get_sp('gcp_token')}"
        publish:
          - trim_token: '${new_string}'
        navigate:
          - SUCCESS: get_access_token
    - get_access_token:
        do:
          io.cloudslang.google.authentication.get_access_token:
            - json_token:
                value: '${trim_token}'
                sensitive: true
            - scopes: 'https://www.googleapis.com/auth/cloud-platform'
            - proxy_host: '${proxy_host}'
        publish:
          - bearer: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_access_token:
        x: 336
        y: 135
        navigate:
          3d646b2a-28f6-883b-d38a-7ee0d327d4b3:
            targetId: f32f953d-95ae-f79a-c1f8-80de9852cf5d
            port: SUCCESS
      trim:
        x: 140
        y: 168
    results:
      SUCCESS:
        f32f953d-95ae-f79a-c1f8-80de9852cf5d:
          x: 482.3333740234375
          y: 99.33334350585938
