#!/usr/bin/env bats
# shellcheck disable=SC2154,SC2219
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[REGISTRY] Setup" {
    info
    setup(){
        skopeo login harbor."${TEST_DOMAIN}" -u admin -p Harbor12345 --tls-verify=false
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[REGISTRY] Deploy busybox image" {
    info
    deploy(){
        skopeo copy docker://library/busybox:1.31 docker://harbor."${TEST_DOMAIN}":"${HTTPS_PORT}"/library/busybox:1.31 --insecure-policy --tls-verify=false
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "[REGISTRY] Check busybox image is in the registry" {
    info
    test(){
        tag=$(curl -k -X GET "https://harbor.${TEST_DOMAIN}:${HTTPS_PORT}/api/v2.0/projects/library/repositories/busybox/artifacts/1.31/tags" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].name)
        if [ "${tag}" != "1.31" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}
