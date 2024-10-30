#!/usr/bin/env bats
# shellcheck disable=SC2154
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[CHARTS] Setup" {
   info
   setup(){
       echo "Adding stable repo" >&3
       helm repo add stable https://charts.helm.sh/stable
       echo "Installing helm-push plugin" >&3
       helm plugin install https://github.com/chartmuseum/helm-push
       echo "Fetching nginx-ingress" >&3
       helm fetch stable/nginx-ingress --version 1.36.2
       echo "Testing Harbor connection" >&3
       curl -k -v https://harbor."${TEST_DOMAIN}":"${HTTPS_PORT}"/api/v2.0/health >&3
       echo "Adding Harbor repo" >&3
       helm repo add --username=admin --password=Harbor12345 harbor-test https://harbor."${TEST_DOMAIN}":"${HTTPS_PORT}"/chartrepo/library --insecure-skip-tls-verify
   }
   run setup
   echo "Setup output: $output" >&3
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
        name=$(curl -k -s -X GET "https://harbor.${TEST_DOMAIN}:${HTTPS_PORT}/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.chart[0].Chart.name')
        version=$(curl -k -s -X GET "https://harbor.${TEST_DOMAIN}:${HTTPS_PORT}/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.chart[0].Chart.version')
        if [ "${name}" != "library/nginx-ingress" ]; then return 1; fi
        if [ "${version}" != "1.36.2" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}
