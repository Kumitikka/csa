namespace: CSA.CloudSlang
flow:
  name: mytest
  workflow:
    - uuid_generator:
        do:
          io.cloudslang.base.utils.uuid_generator: []
        navigate:
          - SUCCESS: sleep
    - sleep:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '3'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      uuid_generator:
        x: 288
        y: 151
      sleep:
        x: 444
        y: 156
        navigate:
          030d4b26-ea43-563d-6c9f-a443fc84a090:
            targetId: 462daefe-b79e-9302-6acf-e4275e15558e
            port: SUCCESS
    results:
      SUCCESS:
        462daefe-b79e-9302-6acf-e4275e15558e:
          x: 603
          y: 151
