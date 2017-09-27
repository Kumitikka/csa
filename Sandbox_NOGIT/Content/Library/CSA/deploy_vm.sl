#   (c) Copyright 2016 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: VM provision flow.
#!
#! @input resource_group_name: The name of the Azure Resource Group that should be used to deploy the VM.
#! @input username: The username to be used to authenticate to the Azure Management Service.
#! @input password: The password to be used to authenticate to the Azure Management Service.
#! @input login_authority: Optional - URL of the login authority that should be used when
#!                         retrieving the Authentication Token.
#!                         Default: 'https://sts.windows.net/common'
#! @input location: Specifies the supported Azure location where the virtual machine should be deployed.
#!                  This can be different from the location of the resource group.
#! @input vm_name: The name of the virtual machine to be deployed.
#!                 Virtual machine name cannot contain non-ASCII or special characters.
#! @input vm_size: The name of the standard Azure VM size to be applied to the VM.
#!                 Example: 'Standard_DS1_v2','Standard_D2_v2','Standard_D3_v2'
#!                 Default: 'Standard_DS1_v2'
#! @input offer: Virtual machine offer
#!               Example: 'WindowsServer','UbuntuServer'
#! @input sku: Version of the operating system to be installed on the virtual machine
#!             Example: '2008-R2-SP1','2008-R2-SP1-BYOL','2012-R2-Datacenter','Windows-Server-Technical-Preview'
#!             '16.04.0-LTS','14.04.0-LTS','12.04.0-LTS','15.04.0-LTS' - for Ubuntu
#! @input publisher: Name of the publisher for the operating system offer and sku
#!                   Example: 'MicrosoftWindowsServer','Canonical'
#! @input virtual_network_name: The name of the virtual network to which the created VM should be attached.
#! @input availability_set_name: Specifies information about the availability set that the virtual machine
#!                               should be assigned to. Virtual machines specified in the same availability set
#!                               are allocated to different nodes to maximize availability.
#! @input storage_account: The name of the storage account in which the OS and Storage disks of the VM should be created.
#! @input subnet_name: The name of the Subnet in which the created VM should be added.
#! @input os_platform: Name of the operating system that will be installed
#!                     Valid values: 'Windows,'Linux'
#! @input vm_username: Specifies the name of the administrator account.
#!                     The username can't contain the \/'[]":\<>+=;,?*@ characters or end with "."
#!                     Windows-only restriction: Cannot end in "."
#!                     Disallowed values: "administrator", "admin", "user", "user1", "test", "user2", "test1",
#!                     "user3", "admin1", "1", "123", "a", "actuser", "adm", "admin2", "aspnet", "backup", "console",
#!                     "david", "guest", "john", "owner", "root", "server", "sql", "support", "support_388945a0",
#!                     "sys", "test2", "test3", "user4", "user5".
#! @input vm_password: Specifies the password of the administrator account.
#!                     Minimum-length (Windows): 8 characters
#!                     Minimum-length (Linux): 6 characters
#!                     Max-length (Windows): 123 characters
#!                     Max-length (Linux): 72 characters
#!                     Complexity requirements: 3 out of 4 conditions below need to be fulfilled
#!                     Has lower characters
#!                     Has upper characters
#!                     Has a digit
#!                     Has a special character (Regex match [\W_])
#!                     Disallowed values: "abc@123", "P@$$w0rd", "P@ssw0rd", "P@ssword123", "Pa$$word", "pass@word1",
#!                     "Password!", "Password1", "Password22", "iloveyou!"
#! @input tag_name: Optional - Name of the tag to be added to the virtual machine
#!                  Default: ''
#! @input tag_value: Optional - Value of the tag to be added to the virtual machine
#!                   Default: ''
#! @input disk_size: The size of the storage disk to be attach to the virtual machine.
#!                   Note: The value must be greater than '0'
#!                   Example: '1'
#! @input connect_timeout: Optional - time in seconds to wait for a connection to be established
#!                         Default: '0' (infinite)
#! @input proxy_host: Optional - proxy server used to access the web site
#! @input proxy_port: Optional - proxy server port - Default: '8080'
#! @input proxy_username: Optional - username used when connecting to the proxy
#! @input proxy_password: Optional - proxy server password associated with the <proxy_username> input value
#! @input trust_all_roots: Optional - specifies whether to enable weak security over SSL - Default: false
#! @input x_509_hostname_verifier: Optional - specifies the way the server hostname must match a domain name in
#!                                 the subject's Common Name (CN) or subjectAltName field of the X.509 certificate
#!                                 Valid: 'strict', 'browser_compatible', 'allow_all' - Default: 'allow_all'
#!                                 Default: 'strict'
#! @input trust_keystore: Optional - the pathname of the Java TrustStore file. This contains certificates from
#!                        other parties that you expect to communicate with, or from Certificate Authorities that
#!                        you trust to identify other parties.  If the protocol (specified by the 'url') is not
#!                        'https' or if trust_all_roots is 'true' this input is ignored.
#!                        Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                        Format: Java KeyStore (JKS)
#! @input trust_password: Optional - the password associated with the trust_keystore file. If trust_all_roots is false
#!                        and trust_keystore is empty, trust_password default will be supplied.
#!
#! @output output: This output returns a JSON that contains the details of the created VM.
#! @output ip_address: The IP address of the virtual machine
#! @output status_code: Equals 200 if the request completed successfully and other status codes in case an error occurred
#! @output return_code: 0 if success, -1 if failure
#! @output error_message: If there is any error while running the flow, it will be populated, empty otherwise
#!
#! @result SUCCESS: The flow completed successfully.
#! @result FAILURE: Something went wrong
#!!#
########################################################################################################################

namespace: CSA
imports:
  strings: io.cloudslang.base.strings
  ip: io.cloudslang.microsoft.azure.compute.network.public_ip_addresses
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json
  auth: io.cloudslang.microsoft.azure.authorization
  nic: io.cloudslang.microsoft.azure.compute.network.network_interface_card
  flow: io.cloudslang.base.utils
  lists: io.cloudslang.base.lists
  vm: io.cloudslang.microsoft.azure.compute.virtual_machines
flow:
  name: deploy_vm
  inputs:
    - subscription_id:
        default: 06f6826c-dbf0-4496-a0fe-a8deaa010547
        private: true
    - resource_group_name: MP1
    - username: csa@mikuphotmail.onmicrosoft.com
    - password:
        default: Point7ACK7.2
        private: true
        sensitive: true
    - login_authority:
        default: 'https://management.azure.com:443'
        required: false
    - location: eastus
    - vm_name: io
    - vm_size: Standard_A0
    - offer: UbuntuServer
    - sku: 12.04.5-LTS
    - publisher: Canonical
    - virtual_network_name: MP1-vnet
    - availability_set_name: CSA
    - storage_account: csadisks
    - subnet_name: default
    - os_platform: Linux
    - vm_username: pkuser
    - vm_password:
        default: P@ssword123456
        private: true
        sensitive: true
    - tag_name:
        default: ''
        required: false
    - tag_value:
        default: ''
        required: false
    - disk_size: '1'
    - connect_timeout:
        default: '0'
        required: false
    - proxy_host:
        default: web-proxy.bbn.hpecorp.net
        required: false
    - proxy_port:
        default: '8080'
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
    - trust_all_roots:
        default: 'true'
        required: false
    - x_509_hostname_verifier:
        default: allow_all
        required: false
    - trust_keystore:
        required: false
    - trust_password:
        required: false
        sensitive: true
    - clientid: 2d363417-ac57-47c7-9281-1d07ac932193
  workflow:
    - get_auth_token:
        do:
          auth.get_auth_token:
            - username
            - password
            - client_id: '${clientid}'
            - login_authority
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
        publish:
          - auth_token
          - error_message: '${exception}'
        navigate:
          - SUCCESS: create_public_ip
          - FAILURE: on_failure
    - create_public_ip:
        do:
          ip.create_public_ip_address:
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
          nic.create_nic:
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
          strings.string_occurrence_counter:
            - string_in_which_to_search: 'Windows,Linux'
            - string_to_find: '${os_platform}'
            - os_platform
        publish:
          - return_code
          - error_message: "${'Cannot create virtual machine with ' + os_platform}"
        navigate:
          - SUCCESS: windows_vm
          - FAILURE: delete_nic
    - windows_vm:
        do:
          strings.string_equals:
            - first_string: '${os_platform}'
            - second_string: Windows
        navigate:
          - SUCCESS: create_windows_vm
          - FAILURE: linux_vm
    - linux_vm:
        do:
          strings.string_equals:
            - first_string: '${os_platform}'
            - second_string: Linux
            - ignore_case: 'true'
        navigate:
          - SUCCESS: create_linux_vm
          - FAILURE: on_failure
    - create_windows_vm:
        do:
          vm.create_windows_vm:
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
    - create_linux_vm:
        do:
          vm.create_linux_vm:
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
    - get_vm_info:
        do:
          vm.get_vm_details:
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
          json.get_value:
            - json_input: '${vm_info}'
            - json_path: 'properties,provisioningState'
        publish:
          - expected_vm_state: '${return_result}'
        navigate:
          - SUCCESS: compare_power_state
          - FAILURE: on_failure
    - compare_power_state:
        do:
          strings.string_equals:
            - first_string: '${expected_vm_state}'
            - second_string: Succeeded
        navigate:
          - SUCCESS: wait_before_check
          - FAILURE: check_failed_power_state
    - check_failed_power_state:
        do:
          strings.string_equals:
            - first_string: '${expected_vm_state}'
            - second_string: Failed
        navigate:
          - SUCCESS: delete_nic
          - FAILURE: wait_between_checks
    - wait_between_checks:
        do:
          flow.sleep:
            - seconds: '60'
        navigate:
          - SUCCESS: get_vm_info
          - FAILURE: on_failure
    - wait_before_check:
        do:
          flow.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: get_vm_public_ip_address
          - FAILURE: on_failure
    - get_vm_public_ip_address:
        do:
          ip.list_public_ip_addresses_within_resource_group:
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
    - get_nic_list:
        do:
          json.json_path_query:
            - json_object: '${ip_details}'
            - json_path: 'value.*.name'
        publish:
          - nics: '${return_result}'
        navigate:
          - SUCCESS: strip_result
          - FAILURE: on_failure
    - strip_result:
        do:
          strings.regex_replace:
            - text: '${nics}'
            - regex: "(\\[|\\])"
            - replacement: ''
        publish:
          - stripped_nic: '${result_text}'
        navigate:
          - SUCCESS: get_nic_location
    - get_nic_location:
        do:
          lists.find_all:
            - list: '${stripped_nic}'
            - element: "${'\"' + vm_name + '-ip' + '\"'}"
            - ignore_case: 'true'
        publish:
          - indices
        navigate:
          - SUCCESS: get_ip_address
    - get_ip_address:
        do:
          json.json_path_query:
            - json_object: '${ip_details}'
            - json_path: "${'value[' + indices + '].properties.ipAddress'}"
        publish:
          - ip_address: '${return_result}'
        navigate:
          - SUCCESS: attach_disk
          - FAILURE: on_failure
    - attach_disk:
        do:
          vm.attach_disk_to_vm:
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
          strings.string_equals:
            - first_string: '${tag_name}'
            - second_string: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: check_tag_value
    - check_tag_value:
        do:
          strings.string_equals:
            - first_string: '${tag_value}'
            - second_string: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: tag_virtual_machine
    - tag_virtual_machine:
        do:
          vm.tag_vm:
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
    - delete_public_ip_address:
        do:
          ip.delete_public_ip_address:
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
          - SUCCESS: on_failure
          - FAILURE: on_failure
    - delete_nic:
        do:
          nic.delete_nic:
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
          flow.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: delete_public_ip_address
          - FAILURE: on_failure
    - wait_for_response:
        do:
          flow.sleep:
            - seconds: '20'
        navigate:
          - SUCCESS: get_nic_list
          - FAILURE: on_failure
  outputs:
    - output
    - ip_address
    - status_code
    - return_code
    - error_message: '${error_message}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      check_vm_state:
        x: 1328
        y: 69
      unsupported_vm:
        x: 561
        y: 283
      wait_for_response:
        x: 1748
        y: 485
      linux_vm:
        x: 733
        y: 260
      strip_result:
        x: 1543
        y: 695
      get_ip_address:
        x: 1116
        y: 695
      create_linux_vm:
        x: 1116
        y: 278
      create_network_interface:
        x: 459
        y: 71
      check_tag_name:
        x: 932
        y: 848
        navigate:
          ba682b82-3df0-81d7-3e03-51c9c602cdfc:
            targetId: 2298ed00-6a9b-35f1-75b2-1e50bf86be9d
            port: SUCCESS
      get_auth_token:
        x: 66
        y: 66
      check_failed_power_state:
        x: 1575
        y: 470
      wait_between_checks:
        x: 1332
        y: 272
      get_vm_info:
        x: 1114
        y: 66
      tag_virtual_machine:
        x: 495
        y: 866
        navigate:
          54d21aae-6fcf-49c4-fb32-9269a4ee3e1a:
            targetId: 2298ed00-6a9b-35f1-75b2-1e50bf86be9d
            port: SUCCESS
      wait_before_nic:
        x: 699
        y: 489
      wait_before_check:
        x: 1749
        y: 66
      windows_vm:
        x: 738
        y: 47
      get_vm_public_ip_address:
        x: 1747
        y: 275
      delete_nic:
        x: 908
        y: 489
      check_tag_value:
        x: 722
        y: 693
        navigate:
          29f763a4-83ad-58eb-31fc-a62b290e40c8:
            targetId: 2298ed00-6a9b-35f1-75b2-1e50bf86be9d
            port: SUCCESS
      get_nic_location:
        x: 1328
        y: 695
      create_windows_vm:
        x: 908
        y: 64
      attach_disk:
        x: 905
        y: 699
      create_public_ip:
        x: 273
        y: 65
      compare_power_state:
        x: 1574
        y: 52
      delete_public_ip_address:
        x: 457
        y: 492
      get_nic_list:
        x: 1747
        y: 694
    results:
      SUCCESS:
        2298ed00-6a9b-35f1-75b2-1e50bf86be9d:
          x: 691
          y: 880
