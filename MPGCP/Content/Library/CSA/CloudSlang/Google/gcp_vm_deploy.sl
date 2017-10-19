namespace: CSA.CloudSlang.Google
flow:
  name: gcp_vm_deploy
  inputs:
    - json_token
    - scopes
    - proxy_host:
        required: false
    - proxy_port:
        required: false
  workflow:
    - get_access_token:
        do:
          io.cloudslang.google.authentication.get_access_token:
            - json_token:
                value: '${json_token}'
                sensitive: true
            - scopes: '${scopes}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
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
        x: 314.6000061035156
        y: 240.39999389648438
        navigate:
          a9fa3cc2-83b1-6e88-c28c-09cff9005210:
            targetId: 895713ef-039d-3c6c-7fa9-4b5342cecc03
            port: SUCCESS
    results:
      SUCCESS:
        895713ef-039d-3c6c-7fa9-4b5342cecc03:
          x: 932.5999755859375
          y: 220.60000610351562
