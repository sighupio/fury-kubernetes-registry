#!/usr/bin/env bats

load "lib/helper"

@test "[REPLICATION] Setup upstream" {
    info
    setup(){
        curl -X POST "https://harbor.${INSTANCE_IP}.nip.io/api/registries" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"name":"dockerhub","type":"docker-hub","url":"https://hub.docker.com","insecure":true}' \
            --user "admin:Harbor12345" --fail
        curl -X POST "https://harbor.${INSTANCE_IP}.nip.io/api/registries/ping" \
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
        docker_hub_registry_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/registries" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -X POST "https://harbor.${INSTANCE_IP}.nip.io/api/replication/policies" \
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
        replication_policy_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -X POST "https://harbor.${INSTANCE_IP}.nip.io/api/replication/executions" \
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
        replication_policy_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        replication_execution_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/replication/executions?policy_id=${replication_policy_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        replication_execution_status=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/replication/executions/${replication_execution_id}" \
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
        curl -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/repositories/library/nginx-prometheus-exporter/tags/0.4.0" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[REPLICATION] Delete" {
    info
    delete(){
        replication_policy_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/replication/policies" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -X DELETE "https://harbor.${INSTANCE_IP}.nip.io/api/replication/policies/${replication_policy_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
        registry_id=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/registries" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].id)
        curl -X DELETE "https://harbor.${INSTANCE_IP}.nip.io/api/registries/${registry_id}" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run delete
    [ "$status" -eq 0 ]
}
