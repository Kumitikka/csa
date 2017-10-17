namespace: treba
flow:
  name: treba
  inputs:
    - timeout_loop:
        default: '4'
        required: false
  workflow:
    - generate_uuid:
        do:
          io.cloudslang.base.math.generate_uuid: []
        navigate:
          - SUCCESS: sleep
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
          - FAILURE: SUCCESS
    - add_numbers:
        do:
          io.cloudslang.base.math.add_numbers:
            - value1: '${timeout_loop}'
            - value2: '1'
        publish:
          - timeout_loop: '${result}'
        navigate:
          - SUCCESS: generate_uuid
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      generate_uuid:
        x: 502
        y: 365
      sleep:
        x: 834
        y: 281
        navigate:
          7d630edd-7605-799c-7d56-ca2b63edc949:
            targetId: fcdee120-344e-b38c-36da-0a51ad912b32
            port: FAILURE
      add_numbers:
        x: 595
        y: 150
    results:
      SUCCESS:
        fcdee120-344e-b38c-36da-0a51ad912b32:
          x: 677
          y: 528
