#!/usr/bin/env bats
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

@test "[NOTARY] Setup" {
    info
    setup(){
        curl -k -X PUT "https://harbor.${TEST_DOMAIN}:${HTTPS_PORT}/api/v2.0/projects/library" \
            -H  "accept: application/json" \
            -H "Content-Type: application/json" \
            --data '{"metadata": {"enable_content_trust": "true","enable_content_trust_cosign": "true"}}' \
            --user "admin:Harbor12345" --fail
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[NOTARY] Try to pull unsigned image" {
    info
    pull(){
        skopeo copy docker://harbor."${TEST_DOMAIN}"/library/busybox:1.31 dir:"$HOME"/busybox:1.31 --insecure-policy --tls-verify=false
    }
    run pull
    [[ "$status" -ne 0 ]]
}
