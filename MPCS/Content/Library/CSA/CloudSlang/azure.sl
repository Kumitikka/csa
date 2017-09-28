namespace: CSA.CloudSlang
flow:
  name: azure
  inputs:
    - username
    - password:
        default: ''
        required: false
        sensitive: true
    - client_id
    - proxy_host
    - proxy_port
  workflow:
    - get_auth_token:
        do:
          io.cloudslang.microsoft.azure.authorization.get_auth_token:
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - client_id: '${client_id}'
            - resource: 'https://management.azure.com'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
        publish:
          - auth_token
          - return_code
          - exception
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_auth_token:
        x: 305
        y: 211
        navigate:
          ea62cc89-b016-3efd-485a-598a42deb21e:
            targetId: cfa3ec53-5e6c-9147-99b8-d30a9862ed1e
            port: SUCCESS
    results:
      SUCCESS:
        cfa3ec53-5e6c-9147-99b8-d30a9862ed1e:
          x: 522
          y: 218
