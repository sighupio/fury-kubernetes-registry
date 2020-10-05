#!/usr/bin/env bats
# Copyright (c) 2020 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[NOTARY] Setup" {
    info
    setup(){
        docker login harbor.${EXTERNAL_DNS} -u admin -p Harbor12345
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[NOTARY] Try to pull unsigned image" {
    info
    pull(){
        export DOCKER_CONTENT_TRUST=1 # Enforcing it
        export DOCKER_CONTENT_TRUST_SERVER=https://notary.${EXTERNAL_DNS} # Using the Notary server
        docker pull harbor.${EXTERNAL_DNS}/library/busybox:1.31
    }
    run pull
    [[ "$output" == *"Error: remote trust data does not exist for harbor.${EXTERNAL_DNS}/library/busybox"* ]]
    [[ "$status" -ne 0 ]]
}
