#   (c) Copyright 2017 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: This operation can be used to create an sql database server
#!
#! @input subscription_id: The ID of the Azure Subscription on which the VM should be created.
#! @input resource_group_name: The name of the Azure Resource Group that should be used to create the VM.
#! @input auth_token: Azure authorization Bearer token
#! @input api_version: The API version used to create calls to Azure
#!                     Default: '2014-04-01-preview'
#! @input location: Specifies the supported Azure location where the sql database server should be created.
#!                  This can be different from the location of the resource group.
#! @input sql_server_name: Sql database server name
#! @input sql_server_state: Specifies the state of the Azure server
#! @input sql_server_version: Specifies the version of the Azure server
#!                            Default '12.0'
#!                            Accepted values:
#!                            2.0 : Indicates a v11 server. If you change the server version from 12.0 to 2.0 on an
#!                            existing server, then the request will fail to complete.
#!                            12.0 : Indicates a v12 server. If you change the server version from 2.0 to 12.0 on an
#!                            existing server, then the server will be migrated from v11 to v12.
#! @input sql_admin_name: Sql database server admin username
#! @input sql_admin_password: Sql database server admin password
#! @input proxy_username: Optional - Username used when connecting to the proxy.
#! @input proxy_password: Optional - Proxy server password associated with the <proxy_username> input value.
#! @input proxy_port: Optional - Proxy server port.
#!                    Default: '8080'
#! @input proxy_host: Optional - Proxy server used to access the web site.
#! @input trust_all_roots: Optional - Specifies whether to enable weak security over SSL.
#!                         Default: 'false'
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
#! @output output: response with information about the created sql database server
#! @output status_code: 200 if request completed successfully, others in case something went wrong
#! @output error_message: If a database is not found the error message will be populated with a response,
#!                        empty otherwise
#!
#! @result SUCCESS: SQL database server created successfully.
#! @result FAILURE: There was an error while trying to create the database server.
#!!#
########################################################################################################################

namespace: CSA.CloudSlang.Subflows
imports:
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json
flow:
  name: create_sql_database_server
  inputs:
    - subscription_id
    - resource_group_name
    - auth_token
    - api_version:
        required: false
        default: 2014-04-01-preview
    - location
    - sql_server_name
    - sql_server_state
    - sql_server_version:
        default: '12.0'
    - sql_admin_name
    - sql_admin_password
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true
    - proxy_port:
        default: '8080'
        required: false
    - proxy_host:
        required: false
    - trust_all_roots:
        default: 'false'
        required: false
    - x_509_hostname_verifier:
        default: strict
        required: false
    - trust_keystore:
        required: false
    - trust_password:
        default: ''
        required: false
        sensitive: true
  workflow:
    - create_sql_database_server:
        do:
          http.http_client_put:
            - url: >
                ${'https://management.azure.com/subscriptions/' + subscription_id + '/resourceGroups/' +
                resource_group_name + '/providers/Microsoft.Sql/servers/' + sql_server_name +
                '?api-version=' + api_version}
            - body: >
                ${'{"location":"' + location + '","tags":{"key":"value"},"properties":{"version":"' +
                sql_server_version + '","administratorLogin":"' +  sql_admin_name +
                '","administratorLoginPassword":"' + sql_admin_password + '"}}'}
            - headers: "${'Authorization: ' + auth_token}"
            - auth_type: anonymous
            - preemptive_auth: 'true'
            - content_type: application/json
            - request_character_set: UTF-8
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password
        publish:
          - output: '${return_result}'
          - status_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: retrieve_error
    - retrieve_error:
        do:
          json.get_value:
            - json_input: '${output}'
            - json_path: 'error,message'
        publish:
          - error_message: '${return_result}'
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
  outputs:
    - output
    - status_code
    - error_message
  results:
    - SUCCESS
    - FAILURE
