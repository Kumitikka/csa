namespace: CSA.CloudSlang
flow:
  name: azure_db
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
    - timeout_loop: '1'
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
          - SUCCESS: create_sql_database_server
          - FAILURE: on_failure
    - create_sql_database:
        do:
          CSA.CloudSlang.Subflows.create_sql_database:
            - subscription_id: '${subscription_id}'
            - resource_group_name: '${resource_group_name}'
            - auth_token: '${auth_token}'
            - location: '${location}'
            - database_name: '${database_name}'
            - sql_server_name: '${sql_server_name}'
            - database_edition: '${database_edition}'
            - requested_service_objective_name: '${requested_service_objective_name}'
            - proxy_port: '${proxy_port}'
            - proxy_host: '${proxy_host}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - create_sql_database_server:
        do:
          CSA.CloudSlang.Subflows.create_sql_database_server:
            - subscription_id: '${subscription_id}'
            - resource_group_name: '${resource_group_name}'
            - auth_token: '${auth_token}'
            - location: '${location}'
            - sql_server_name: '${sql_server_name}'
            - sql_server_state: '${sql_server_state}'
            - sql_admin_name: '${sql_admin_name}'
            - sql_admin_password: '${sql_admin_password}'
            - proxy_port: '${proxy_port}'
            - proxy_host: '${proxy_host}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
        publish:
          - do_retry: '${status_code}'
        navigate:
          - SUCCESS: create_sql_database
          - FAILURE: string_equals
    - string_equals:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${do_retry}'
            - second_string: '504'
        navigate:
          - SUCCESS: sleep
          - FAILURE: on_failure
    - sleep:
        loop:
          for: 'timeout_loop in 1,2,3'
          do:
            io.cloudslang.base.utils.sleep:
              - seconds: '2'
          break:
            - FAILURE
        navigate:
          - SUCCESS: add_numbers
          - FAILURE: on_failure
    - add_numbers:
        do:
          io.cloudslang.base.math.add_numbers:
            - value1: '${timeout_loop}'
            - value2: '1'
        publish:
          - timeout_loop: '${result}'
        navigate:
          - SUCCESS: create_sql_database_server
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
      create_sql_database:
        x: 511
        y: 100
        navigate:
          5d131b2a-efde-3b5f-89e6-ec4644e2544f:
            targetId: 424eb293-6dec-7667-ac65-e15e1bd37f48
            port: SUCCESS
      create_sql_database_server:
        x: 323
        y: 114
        navigate:
          308e869f-3cdb-a8b5-3029-2c2761c5fd37:
            vertices:
              - x: 363
                y: 297
            targetId: string_equals
            port: FAILURE
      string_equals:
        x: 452
        y: 295
      sleep:
        x: 245
        y: 361
      add_numbers:
        x: 75
        y: 295
    results:
      SUCCESS:
        424eb293-6dec-7667-ac65-e15e1bd37f48:
          x: 676.3333740234375
          y: 95.33334350585938
