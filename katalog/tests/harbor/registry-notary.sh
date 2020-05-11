#!/usr/bin/env bats

load "./../lib/helper"

@test "[NOTARY] Setup" {
    info
    setup(){
        docker login harbor.${INSTANCE_IP}.nip.io -u admin -p Harbor12345
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[NOTARY] Try to pull unsigned image" {
    info
    pull(){
        export DOCKER_CONTENT_TRUST=1 # Enforcing it
        export DOCKER_CONTENT_TRUST_SERVER=https://notary.${INSTANCE_IP}.nip.io # Using the Notary server
        docker pull harbor.${INSTANCE_IP}.nip.io/library/busybox:1.31
    }
    run pull
    [[ "$output" == *"Error: remote trust data does not exist for harbor.${INSTANCE_IP}.nip.io/library/busybox"* ]]
    [[ "$status" -ne 0 ]]
}
