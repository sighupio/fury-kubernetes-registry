#!/usr/bin/env bats
# shellcheck disable=SC2154
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[CHARTS] Setup" {
    info
    setup(){
        helm repo add stable https://charts.helm.sh/stable 
        helm plugin install https://github.com/chartmuseum/helm-push
        helm fetch stable/nginx-ingress --version 1.36.2
        helm repo add --username=admin --password=Harbor12345 harbor-test https://harbor."${EXTERNAL_DNS}"/chartrepo/library --insecure-skip-tls-verify
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[CHARTS] Push nginx ingress chart to Harbor" {
    info
    deploy(){
        helm cm-push nginx-ingress-1.36.2.tgz harbor-test --insecure
    }
    run deploy
    [ "$status" -eq 0 ]
}


@test "[CHARTS] Check nginx ingress is in chartmuseum" {
    info
    test(){
        name=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.chart[0].Chart.name')
        version=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.chart[0].Chart.version')
        if [ "${name}" != "library/nginx-ingress" ]; then return 1; fi
        if [ "${version}" != "1.36.2" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}
