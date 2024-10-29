#!/usr/bin/env bats
# shellcheck disable=SC2154,SC2219
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


load "./../lib/helper"

@test "[VULNS] Setup" {
    info
    setup(){
        skopeo login harbor."${EXTERNAL_DNS}" -u admin -p Harbor12345 --tls-verify=false
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[VULNS] Deploy insecure image" {
    info
    deploy(){
        skopeo copy docker://vulnerables/web-dvwa:1.9 docker://harbor."${EXTERNAL_DNS}"/library/web-dvwa:1.9 --insecure-policy --tls-verify=false
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "[VULNS] Check insecure image is in the registry" {
    info
    test(){
        tag=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/web-dvwa/artifacts/1.9/tags" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.[0].name')
        if [ "${tag}" != "1.9" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[VULNS] Check scanner status" {
    info
    test(){
        health=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/1/scanner" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.health')
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
        curl -k -X POST "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/web-dvwa/artifacts/1.9/scan" \
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
            scan_status=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/web-dvwa/artifacts/1.9?with_scan_overview=true" \
                -H  "accept: application/json" \
                -H 'x-accept-vulnerabilities: application/vnd.security.vulnerability.report; version=1.1' \
                --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.security.vulnerability.report; version=1.1"].scan_status')
            echo "#     Scan status is: '${scan_status}'" >&3
            if [ "${scan_status}" != "Success" ]; then echo "#     Scan is not ready yet" >&3; let "retries+=1"; sleep ${retry_seconds}; fi
        done
        if [ "${scan_status}" != "Success" ]; then return 1; fi
        # See scan report
        echo "#   Checking scan report" >&3
        vulns=$(curl -k -s -X GET "https://harbor.${EXTERNAL_DNS}/api/v2.0/projects/library/repositories/web-dvwa/artifacts/1.9?with_scan_overview=true" \
            -H  "accept: application/json" \
            -H 'x-accept-vulnerabilities: application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0' \
            --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.security.vulnerability.report; version=1.1"].summary.total')
        echo "#     Vulnerabilities is: '${vulns}'" >&3
        if [ "${vulns}" == "null" ]; then echo "#     No vulnerabilities found. Retrying" >&3; return 1; fi
        if [ "${vulns}" -eq "0" ]; then echo "#     No vulnerabilities found. Retrying" >&3; return 1; fi
    }
    loop_it test 10 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
