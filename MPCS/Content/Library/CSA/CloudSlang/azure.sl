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
    - subscription_id
    - resource_group_name
    - connect_timeout: '0'
    - location
    - trust_all_roots: 'true'
    - x_509_hostname_verifier: allow_all
    - vm_name
  workflow:
    - get_auth_token:
        do:
          io.cloudslang.microsoft.azure.authorization.get_auth_token:
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - client_id: '${client_id}'
            - login_authority: 'https://management.azure.com:443/'
            - resource: 'https://management.azure.com'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
        publish:
          - auth_token
          - return_code
          - exception
        navigate:
          - SUCCESS: create_public_ip
          - FAILURE: on_failure
    - create_public_ip:
        do:
          io.cloudslang.microsoft.azure.compute.network.public_ip_addresses.create_public_ip_address:
            - vm_name
            - location
            - subscription_id
            - resource_group_name
            - public_ip_address_name: "${vm_name + '-ip'}"
            - auth_token
            - connect_timeout
            - socket_timeout: '0'
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password
        publish:
          - ip_state: '${output}'
          - status_code
          - error_message
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
      create_public_ip:
        x: 494
        y: 210
        navigate:
          8b6a8283-ac20-4820-248b-7c29c7de65ea:
            targetId: cfa3ec53-5e6c-9147-99b8-d30a9862ed1e
            port: SUCCESS
    results:
      SUCCESS:
        cfa3ec53-5e6c-9147-99b8-d30a9862ed1e:
          x: 721
          y: 201
