namespace: treba
flow:
  name: donothing
  workflow:
    - sleep:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '10'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      sleep:
        x: 254.60000610351562
        y: 138.60000610351562
        navigate:
          c1c0a46f-4876-079e-cd61-0e252f158bb0:
            targetId: 62f48060-3de4-ed4b-2cfd-5ee92fae2a69
            port: SUCCESS
    results:
      SUCCESS:
        62f48060-3de4-ed4b-2cfd-5ee92fae2a69:
          x: 583.5999755859375
          y: 117.39999389648438
