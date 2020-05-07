#!/usr/bin/env bats

load "lib/helper"

@test "[CLAIR] Setup" {
    info
    setup(){
        docker pull ubuntu:16.04
        docker login harbor.${INSTANCE_IP}.nip.io -u admin -p Harbor12345
    }
    run setup
    [ "$status" -eq 0 ]
}

@test "[CLAIR] Deploy insecure image" {
    info
    deploy(){
        docker tag ubuntu:16.04 harbor.${INSTANCE_IP}.nip.io/library/ubuntu:16.04
        docker push harbor.${INSTANCE_IP}.nip.io/library/ubuntu:16.04
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "[CLAIR] Check insecure image is in the registry" {
    info
    test(){
        curl -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/repositories/library/ubuntu/tags/16.04" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[CLAIR] Check clair status" {
    info
    test(){
        health=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/projects/1/scanner" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r .health)
        if [ "${health}" != "healthy" ]; then return 1; fi
    }
    run test
    [ "$status" -eq 0 ]
}

@test "[CLAIR] Scan an insecure image" {
    info
    test(){
        # Trigger Scan
        echo "#   Trigger the scan" >&3
        curl -X POST "https://harbor.${INSTANCE_IP}.nip.io/api/repositories/library/ubuntu/tags/16.04/scan" \
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
            scan_status=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/repositories/library/ubuntu/tags/16.04?detail=true" \
                -H  "accept: application/json" \
                --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0"].scan_status')
            if [ "${scan_status}" != "Success" ]; then echo "#     Scan is not ready yet" >&3; let "retries+=1"; sleep ${retry_seconds}; fi
        done
        if [ "${scan_status}" != "Success" ]; then return 1; fi
        # See scan report
        echo "#   Checking scan report" >&3
        vulns=$(curl -s -X GET "https://harbor.${INSTANCE_IP}.nip.io/api/repositories/library/ubuntu/tags/16.04?detail=true" \
            -H  "accept: application/json" \
            --user "admin:Harbor12345" --fail | jq -r '.scan_overview["application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0"].summary.total')
        if [ "${vulns}" -eq "0" ]; then echo "#     No vulnerabilities found. Retrying" >&3; return 1; fi
    }
    loop_it test 30 60
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
