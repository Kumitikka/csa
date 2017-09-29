namespace: CSA.CloudSlang
flow:
  name: azure_vm
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
    - vm_name
    - vm_username:
        sensitive: true
    - vm_password
    - nic_name:
        required: false
    - virtual_network_name
    - subnet_name
    - os_platform
    - availability_set_name
    - storage_account
    - vm_size
    - publisher
    - sku
    - offer
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
          - SUCCESS: create_network_interface
          - FAILURE: on_failure
    - create_network_interface:
        do:
          io.cloudslang.microsoft.azure.compute.network.network_interface_card.create_nic:
            - vm_name
            - nic_name: "${vm_name + '-nic'}"
            - location
            - subscription_id
            - resource_group_name
            - public_ip_address_name: "${vm_name + '-ip'}"
            - virtual_network_name
            - subnet_name
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
          - nic_state: '${output}'
          - status_code
          - error_message: '${error_message}'
        navigate:
          - SUCCESS: unsupported_vm
          - FAILURE: delete_public_ip_address
    - unsupported_vm:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: 'Windows,Linux'
            - string_to_find: '${os_platform}'
            - os_platform
        publish:
          - return_code
          - error_message: "${'Cannot create virtual machine with ' + os_platform}"
          - return_result
        navigate:
          - SUCCESS: windows_vm
          - FAILURE: on_failure
    - windows_vm:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${os_platform}'
            - second_string: Windows
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: linux_vm
    - linux_vm:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${os_platform}'
            - second_string: Linux
            - ignore_case: 'true'
        navigate:
          - SUCCESS: create_linux_vm
          - FAILURE: on_failure
    - create_linux_vm:
        do:
          io.cloudslang.microsoft.azure.compute.virtual_machines.create_linux_vm:
            - subscription_id
            - publisher
            - auth_token
            - sku
            - offer
            - resource_group_name
            - vm_name
            - nic_name: "${vm_name + '-nic'}"
            - location
            - vm_username
            - vm_password
            - vm_size
            - availability_set_name
            - storage_account
            - connect_timeout
            - socket_timeout: '0'
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
        publish:
          - vm_state: '${output}'
          - status_code: '${status_code}'
          - error_message: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: delete_nic
    - delete_nic:
        do:
          io.cloudslang.microsoft.azure.compute.network.network_interface_card.delete_nic:
            - nic_name: "${vm_name + '-nic'}"
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
        navigate:
          - SUCCESS: wait_before_nic
          - FAILURE: on_failure
    - wait_before_nic:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: delete_public_ip_address
          - FAILURE: on_failure
    - delete_public_ip_address:
        do:
          io.cloudslang.microsoft.azure.compute.network.public_ip_addresses.delete_public_ip_address:
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
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      unsupported_vm:
        x: 601
        y: 105
      linux_vm:
        x: 848
        y: 273
      create_linux_vm:
        x: 1089
        y: 286
        navigate:
          edb10b09-5a39-1e4c-4ac0-b6dfb2e62892:
            targetId: 5991eb74-fa2d-4860-5a6e-b926236e3e65
            port: SUCCESS
      create_network_interface:
        x: 446
        y: 105
      get_auth_token:
        x: 93
        y: 104
      wait_before_nic:
        x: 629
        y: 469
      windows_vm:
        x: 837
        y: 87
        navigate:
          495131d7-7391-da1b-649e-b79312afe9b1:
            targetId: 5991eb74-fa2d-4860-5a6e-b926236e3e65
            port: SUCCESS
      delete_nic:
        x: 824
        y: 454
      create_public_ip:
        x: 276
        y: 103
      delete_public_ip_address:
        x: 443
        y: 465
        navigate:
          781ff6e8-1793-6665-da01-9deecf034ffd:
            targetId: b01abab3-58a6-5092-2594-cde6e3544a31
            port: SUCCESS
    results:
      SUCCESS:
        5991eb74-fa2d-4860-5a6e-b926236e3e65:
          x: 1085
          y: 101
      FAILURE:
        b01abab3-58a6-5092-2594-cde6e3544a31:
          x: 151
          y: 415
