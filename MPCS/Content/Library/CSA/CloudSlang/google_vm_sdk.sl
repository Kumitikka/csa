namespace: CSA.CloudSlang
flow:
  name: google_vm_sdk
  inputs:
    - host: 192.168.127.72
    - command: 'gcloud compute --project "${gcloud_project}" instances create "${gcloud_instances}" --zone "${gcloud_zone}" --machine-type "${gcloud_machine-type}" --subnet "${gcloud_subnet}" --maintenance-policy "MIGRATE" --service-account "${gcloud_service-account}" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "${gcloud_image}" --image-project "${gcloud_image-project}" --boot-disk-size "${gcloud_boot-disk-size}" --boot-disk-type "pd-standard" --boot-disk-device-name "${gcloud_boot-disk-device-name}"'
    - gcloud_project: ''
    - gcloud_instances: pannu
    - gcloud_zone: us-central1-c
    - gcloud_machine_type: f1-micro
    - gcloud_subnet: default
    - gcloud_service_account: ''
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
            - command: 'gcloud compute --project "${gcloud_project}" instances create "${gcloud_instances}" --zone "${gcloud_zone}" --machine-type "${gcloud_machine_type}" --subnet "${gcloud_subnet}" --maintenance-policy "MIGRATE" --service-account "${gcloud_service_account}" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "${gcloud_image}" --image-project "${gcloud_image_project}" --boot-disk-size "${gcloud_boot_disk_size}" --boot-disk-type "pd-standard" --boot-disk-device-name "${gcloud_instances}"'
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
        x: 201
        y: 300
        navigate:
          732041ab-bdc8-5a31-55fe-2835214977f9:
            targetId: 2f38f462-23a6-d521-6997-da4e7659faa4
            port: SUCCESS
    results:
      SUCCESS:
        2f38f462-23a6-d521-6997-da4e7659faa4:
          x: 435.3333435058594
          y: 262.3333435058594
