#!/usr/bin/env bats
# shellcheck disable=SC2154,SC2219
# Copyright (c) 2020 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[VULNS] Setup" {
    info
    setup(){
        docker pull ubuntu:16.04
        docker login harbor."${EXTERNAL_DNS}" -u admin -p Harbor12345
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[VULNS] Deploy insecure image" {
    info
    deploy(){
        docker tag ubuntu:16.04 harbor."${EXTERNAL_DNS}"/library/ubuntu:16.04
        docker push harbor."${EXTERNAL_DNS}"/library/ubuntu:16.04
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "[VULNS] Check insecure image is in the registry" {
    info
    test(){
        tag=$(curl -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/ubuntu/artifacts/16.04/tags" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .[0].name)
        if [ "${tag}" != "16.04" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[VULNS] Check scanner status" {
    info
    test(){
        health=$(curl -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/1/scanner" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .health)
        if [ "${health}" != "healthy" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[VULNS] Scan an insecure image" {
    info
    test(){
        # Trigger Scan
        echo "#   Trigger the scan" >&3
        curl -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/ubuntu/artifacts/16.04/scan" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
        # Wait for scan
        retries=0
        mas_retries=10
        retry_seconds=5
        scan_status=""
        echo "#   Wait to get the scan report" >&3
        while [[ "${scan_status}" != "Success" ]] && [[ "${retries}" -lt ${mas_retries} ]]
        do
            scan_status=$(curl -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/ubuntu/artifacts/16.04?with_scan_overview=true" \
                -H  "accept: application/json" \
                -H 'x-accept-vulnerabilities: application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0' \
                --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0"].scan_status')
            if [ "${scan_status}" != "Success" ]; then echo "#     Scan is not ready yet" >&3; let "retries+=1"; sleep ${retry_seconds}; fi
        done
        if [ "${scan_status}" != "Success" ]; then return 1; fi
        # See scan report
        echo "#   Checking scan report" >&3
        vulns=$(curl -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/ubuntu/artifacts/16.04?with_scan_overview=true" \
            -H  "accept: application/json" \
            -H 'x-accept-vulnerabilities: application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0' \
            --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0"].summary.total')
        if [ "${vulns}" == "null" ]; then echo "#     No vulnerabilities found. Retrying" >&3; return 1; fi
        if [ "${vulns}" -eq "0" ]; then echo "#     No vulnerabilities found. Retrying" >&3; return 1; fi
    }
    loop_it test 30 60
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
