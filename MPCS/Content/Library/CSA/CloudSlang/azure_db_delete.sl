namespace: CSA.CloudSlang
flow:
  name: azure_db_delete
  inputs:
    - username
    - password:
        sensitive: true
    - client_id:
        sensitive: true
    - proxy_host
    - proxy_port
    - subscription_id:
        sensitive: true
    - resource_group_name
    - connect_timeout: '0'
    - location
    - trust_all_roots: 'true'
    - x_509_hostname_verifier: allow_all
    - sql_server_name
    - sql_server_state:
        required: false
    - sql_admin_name
    - sql_admin_password
    - database_name
    - database_edition
    - requested_service_objective_name
  workflow:
    - get_auth_token:
        do:
          io.cloudslang.microsoft.azure.authorization.get_auth_token:
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - client_id: '${client_id}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
        publish:
          - auth_token
          - return_code
          - exception
        navigate:
          - SUCCESS: delete_sql_database
          - FAILURE: on_failure
    - delete_sql_database:
        do:
          io.cloudslang.microsoft.azure.databases.delete_sql_database:
            - subscription_id: '${subscription_id}'
            - resource_group_name: '${resource_group_name}'
            - auth_token: '${auth_token}'
            - server_name: '${sql_server_name}'
            - database_name: '${database_name}'
            - proxy_port: '${proxy_port}'
            - proxy_host: '${proxy_host}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_auth_token:
        x: 93
        y: 104
      delete_sql_database:
        x: 371.6187744140625
        y: 96.60000610351562
        navigate:
          5e521302-b57e-aa38-e93e-57c681b83ffa:
            targetId: 424eb293-6dec-7667-ac65-e15e1bd37f48
            port: SUCCESS
    results:
      SUCCESS:
        424eb293-6dec-7667-ac65-e15e1bd37f48:
          x: 676.3333740234375
          y: 95.33334350585938
