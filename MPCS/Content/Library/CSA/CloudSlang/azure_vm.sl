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
    - disk_size
    - tag_name: Workflow
    - tag_value: CloudSlang
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
          - SUCCESS: create_windows_vm
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
          - SUCCESS: get_vm_info
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
    - get_vm_info:
        do:
          io.cloudslang.microsoft.azure.compute.virtual_machines.get_vm_details:
            - subscription_id
            - resource_group_name
            - vm_name
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
          - vm_info: '${output}'
          - status_code
          - error_message
        navigate:
          - SUCCESS: check_vm_state
          - FAILURE: on_failure
    - check_vm_state:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${vm_info}'
            - json_path: 'properties,provisioningState'
        publish:
          - expected_vm_state: '${return_result}'
        navigate:
          - SUCCESS: compare_power_state
          - FAILURE: on_failure
    - compare_power_state:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${expected_vm_state}'
            - second_string: Succeeded
        navigate:
          - SUCCESS: wait_before_check
          - FAILURE: check_failed_power_state
    - wait_before_check:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: get_vm_public_ip_address
          - FAILURE: on_failure
    - get_vm_public_ip_address:
        do:
          io.cloudslang.microsoft.azure.compute.network.public_ip_addresses.list_public_ip_addresses_within_resource_group:
            - subscription_id
            - resource_group_name
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
          - ip_details: '${output}'
          - status_code
          - error_message: '${error_message}'
        navigate:
          - SUCCESS: wait_for_response
          - FAILURE: on_failure
    - wait_for_response:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: get_nic_list
          - FAILURE: on_failure
    - get_nic_list:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${ip_details}'
            - json_path: 'value.*.name'
        publish:
          - nics: '${return_result}'
        navigate:
          - SUCCESS: strip_result
          - FAILURE: on_failure
    - strip_result:
        do:
          io.cloudslang.base.strings.regex_replace:
            - text: '${nics}'
            - regex: "(\\[|\\])"
            - replacement: ''
        publish:
          - stripped_nic: '${result_text}'
        navigate:
          - SUCCESS: get_nic_location
    - get_nic_location:
        do:
          io.cloudslang.base.lists.find_all:
            - list: '${stripped_nic}'
            - element: "${'\"' + vm_name + '-ip' + '\"'}"
            - ignore_case: 'true'
        publish:
          - indices
        navigate:
          - SUCCESS: get_ip_address
    - get_ip_address:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${ip_details}'
            - json_path: "${'value[' + indices + '].properties.ipAddress'}"
        publish:
          - ip_address: '${return_result}'
        navigate:
          - SUCCESS: attach_disk
          - FAILURE: on_failure
    - attach_disk:
        do:
          io.cloudslang.microsoft.azure.compute.virtual_machines.attach_disk_to_vm:
            - subscription_id
            - location
            - resource_group_name
            - auth_token
            - vm_name
            - storage_account
            - disk_name: '${vm_name}'
            - disk_size
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
          - status_code
          - error_message: '${error_message}'
        navigate:
          - SUCCESS: check_tag_name
          - FAILURE: on_failure
    - check_tag_name:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${tag_name}'
            - second_string: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: check_tag_value
    - check_tag_value:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${tag_value}'
            - second_string: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: tag_virtual_machine
    - tag_virtual_machine:
        do:
          io.cloudslang.microsoft.azure.compute.virtual_machines.tag_vm:
            - subscription_id
            - resource_group_name
            - location
            - vm_name
            - auth_token
            - tag_name
            - tag_value
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
          - status_code
          - error_message: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - create_windows_vm:
        do:
          io.cloudslang.microsoft.azure.compute.virtual_machines.create_windows_vm:
            - subscription_id
            - resource_group_name
            - vm_name
            - nic_name: "${vm_name + '-nic'}"
            - location
            - vm_username
            - vm_password
            - vm_size
            - publisher
            - sku
            - offer
            - availability_set_name
            - storage_account
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
          - vm_state: '${output}'
          - status_code
          - error_message
        navigate:
          - SUCCESS: get_vm_info
          - FAILURE: delete_nic
    - check_failed_power_state:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${expected_vm_state}'
            - second_string: Failed
        navigate:
          - SUCCESS: delete_nic
          - FAILURE: wait_between_checks
    - wait_between_checks:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '30'
        navigate:
          - SUCCESS: get_vm_info
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      check_vm_state:
        x: 1215
        y: 111
      unsupported_vm:
        x: 601
        y: 105
      wait_for_response:
        x: 1646
        y: 614
      linux_vm:
        x: 848
        y: 273
      strip_result:
        x: 1279
        y: 634
      get_ip_address:
        x: 924
        y: 637
      create_linux_vm:
        x: 1065
        y: 402
      create_network_interface:
        x: 446
        y: 105
      check_tag_name:
        x: 629
        y: 634
        navigate:
          b8e0fa06-b89e-5f5b-6097-498182d208bb:
            targetId: 5991eb74-fa2d-4860-5a6e-b926236e3e65
            port: SUCCESS
      get_auth_token:
        x: 93
        y: 104
        navigate:
          10ecd2e7-e763-1d40-d300-5c7d94a6b2e8:
            vertices:
              - x: 171
                y: 132
              - x: 266
                y: 140
            targetId: create_public_ip
            port: SUCCESS
      check_failed_power_state:
        x: 1498
        y: 452
      wait_between_checks:
        x: 1352
        y: 292
      get_vm_info:
        x: 1186
        y: 278
      tag_virtual_machine:
        x: 215
        y: 647
        navigate:
          d09f2b4f-858d-b8b2-2699-dea8f180238b:
            targetId: 5991eb74-fa2d-4860-5a6e-b926236e3e65
            port: SUCCESS
      wait_before_nic:
        x: 629
        y: 469
      wait_before_check:
        x: 1619
        y: 115
      windows_vm:
        x: 837
        y: 87
      get_vm_public_ip_address:
        x: 1633
        y: 325
      delete_nic:
        x: 823
        y: 460
      check_tag_value:
        x: 444
        y: 779
        navigate:
          e55d26f6-93dd-4b45-6d8a-0385724b4a68:
            targetId: 5991eb74-fa2d-4860-5a6e-b926236e3e65
            port: SUCCESS
      get_nic_location:
        x: 1098
        y: 641
      create_windows_vm:
        x: 958
        y: 113
      attach_disk:
        x: 773
        y: 646
      create_public_ip:
        x: 276
        y: 103
      compare_power_state:
        x: 1446
        y: 108
      delete_public_ip_address:
        x: 443
        y: 465
        navigate:
          781ff6e8-1793-6665-da01-9deecf034ffd:
            targetId: b01abab3-58a6-5092-2594-cde6e3544a31
            port: SUCCESS
      get_nic_list:
        x: 1416
        y: 618
    results:
      SUCCESS:
        5991eb74-fa2d-4860-5a6e-b926236e3e65:
          x: 417
          y: 638
      FAILURE:
        b01abab3-58a6-5092-2594-cde6e3544a31:
          x: 151
          y: 415
