namespace: CSA.CloudSlang
flow:
  name: tmp
  inputs:
    - os_platform: Linux
  workflow:
    - unsupported_vm:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: 'Windows,Linux'
            - string_to_find: '${os_platform}'
            - os_platform
        publish:
          - return_code
          - error_message: "${'Cannot create virtual machine with ' + os_platform}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      unsupported_vm:
        x: 819
        y: 233
        navigate:
          23bb1271-0748-91a8-05bf-8d02d6d5d2fa:
            targetId: 6c8d287b-5d3a-5c20-7ffc-85d0290ce7bb
            port: SUCCESS
    results:
      SUCCESS:
        6c8d287b-5d3a-5c20-7ffc-85d0290ce7bb:
          x: 972.3333740234375
          y: 186.33334350585938
