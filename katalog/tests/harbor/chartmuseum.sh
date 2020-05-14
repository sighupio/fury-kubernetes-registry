#!/usr/bin/env bats

load "./../lib/helper"

@test "[CHARTS] Setup" {
    info
    setup(){
        helm init --client-only
        helm plugin install https://github.com/chartmuseum/helm-push
        helm fetch stable/nginx-ingress --version 1.36.2
        helm repo add --username=admin --password=Harbor12345 harbor-test https://harbor.${INSTANCE_IP}.sslip.io/chartrepo/library
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[CHARTS] Deploy nginx ingress chart" {
    info
    deploy(){
        helm push --username=admin --password=Harbor12345 nginx-ingress-1.36.2.tgz harbor-test
    }
    run deploy
    [ "$status" -eq 0 ]
}


@test "[CHARTS] Check nginx ingress is in chartmuseum" {
    info
    test(){
        name=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.sslip.io/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .chart[0].Chart.name)
        version=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.sslip.io/api/v2.0/search?q=nginx-ingress" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .chart[0].Chart.version)
        if [ "${name}" != "library/nginx-ingress" ]; then return 1; fi
        if [ "${version}" != "1.36.2" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}
