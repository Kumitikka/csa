namespace: CSA.CloudSlang
flow:
  name: google_vm_sdk
  inputs:
    - host: 192.168.127.72
    - command: 'gcloud compute --project uplifted-mantra-167311  instances create pannu  --zone us-central1-c --machine-type f1-micro --subnet default --maintenance-policy "MIGRATE" --service-account csa-909@uplifted-mantra-167311.iam.gserviceaccount.com --scopes ""https://www.googleapis.com/auth/cloud-platform"" --image ubuntu-1404-trusty-v20170505  --image-project ubuntu-os-cloud  --boot-disk-size 10  --boot-disk-type pd-standard --boot-disk-device-name pannudsk'
    - gcloud_project: uplifted-mantra-167311
    - gcloud_instances: pannu
    - gcloud_zone: us-central1-c
    - gcloud_machine_type: f1-micro
    - gcloud_subnet: default
    - gcloud_service_account: csa-909@uplifted-mantra-167311.iam.gserviceaccount.com
    - gcloud_image: ubuntu-1404-trusty-v20170505
    - gcloud_image_project: ubuntu-os-cloud
    - gcloud_boot_disk_size: '10'
    - username: "${get_sp('lnx_admin')}"
    - password: "${get_sp('lnx_password')}"
  workflow:
    - ssh_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: '${command}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      ssh_command:
        x: 278
        y: 201
        navigate:
          732041ab-bdc8-5a31-55fe-2835214977f9:
            targetId: 2f38f462-23a6-d521-6997-da4e7659faa4
            port: SUCCESS
    results:
      SUCCESS:
        2f38f462-23a6-d521-6997-da4e7659faa4:
          x: 435.3333435058594
          y: 262.3333435058594
