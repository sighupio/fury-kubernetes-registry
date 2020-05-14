#!/usr/bin/env bats

load "./../lib/helper"

@test "[REGISTRY] Setup" {
    info
    setup(){
        docker pull busybox:1.31
        docker login harbor.${INSTANCE_IP}.sslip.io -u admin -p Harbor12345
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[REGISTRY] Deploy busybox image" {
    info
    deploy(){
        docker tag busybox:1.31 harbor.${INSTANCE_IP}.sslip.io/library/busybox:1.31
        docker push harbor.${INSTANCE_IP}.sslip.io/library/busybox:1.31
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "[REGISTRY] Check busybox image is in the registry" {
    info
    test(){
        tag=$(curl -X GET "https://harbor.${INSTANCE_IP}.sslip.io/api/v2.0/projects/library/repositories/busybox/artifacts/1.31/tags" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].name)
        if [ "${tag}" != "1.31" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}
