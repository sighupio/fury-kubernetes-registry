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
        curl -X GET "https://harbor.${INSTANCE_IP}.sslip.io/api/repositories/library/busybox/tags/1.31" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run test
    [ "$status" -eq 0 ]
}
