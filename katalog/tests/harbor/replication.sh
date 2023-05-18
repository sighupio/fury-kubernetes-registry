#!/usr/bin/env bats
# shellcheck disable=SC2154
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[REPLICATION] Setup upstream" {
    info
    setup(){
        curl -k -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/registries" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"name":"dockerhub","type":"docker-hub","url":"https://hub.docker.com","insecure":true}' \
            --user "admin:Harbor12345" --fail
        curl -k -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/registries/ping" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"name":"dockerhub","type":"docker-hub","url":"https://hub.docker.com","insecure":true}' \
            --user "admin:Harbor12345" --fail
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[REPLICATION] Setup testing replication policy" {
    info
    setup(){
        docker_hub_registry_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/registries" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -k -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/policies" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"name":"test-from-dockerhub","src_registry":{"id":'"${docker_hub_registry_id}"'},"dest_registry":{"id":0},"dest_namespace":"library","filters":[{"type":"name","value":"nginx/nginx-prometheus-exporter"},{"type":"tag","value":"0.4.*"}],"trigger":{"type":"manual"},"deletion":false,"override":true,"enabled":true}' \
            --user "admin:Harbor12345" --fail
    }
    run setup
    [ "$status" -eq 0 ]
}


@test "[REPLICATION] Start test replication policy" {
    info
    start(){
        replication_policy_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -k -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/executions" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"policy_id":'"${replication_policy_id}"'}' \
            --user "admin:Harbor12345" --fail
    }
    run start
    [ "$status" -eq 0 ]
}

@test "[REPLICATION] Check replication execution" {
    info
    test(){
        replication_policy_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        replication_execution_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/executions?policy_id=${replication_policy_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        replication_execution_status=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/executions/${replication_execution_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .status)
        if [ "${replication_execution_status}" != "Succeed" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[REPLICATION] Check replicated images are available in harbor" {
    info
    test(){
        curl -k -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/nginx-prometheus-exporter/artifacts/0.4.0" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[REPLICATION] Delete" {
    info
    delete(){
        replication_policy_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -k -X DELETE "https://harbor.${EXTERNAL_DNS}/api/v2.0/replication/policies/${replication_policy_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
        registry_id=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/registries" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -k -X DELETE "https://harbor.${EXTERNAL_DNS}/api/v2.0/registries/${registry_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run delete
    [ "$status" -eq 0 ]
}
