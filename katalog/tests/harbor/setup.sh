#!/usr/bin/env bats

load "./../lib/helper"

@test "[SETUP] pre-requirements - CRDs" {
    info
    crds(){
        kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.6.1/katalog/prometheus-operator/crd-prometheus.yml
        kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.6.1/katalog/prometheus-operator/crd-servicemonitor.yml
        kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.6.1/katalog/prometheus-operator/crd-rule.yml
    }
    run crds
    [ "$status" -eq 0 ]
}

@test "[SETUP] requirements - ingress" {
    info
    install_ingress(){
        cd katalog/tests/harbor/config
        furyctl vendor -H
        cd -
        kustomize build katalog/tests/harbor/config | kubectl apply -f -
    }
    loop_it install_ingress 20 3
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[SETUP] requirements - Check Ingress" {
    info
    test(){
        status=$(kubectl get pods -n ingress-nginx -l app=ingress-nginx -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[SETUP] requirements - Check cert-manager" {
    info
    test(){
        status=$(kubectl get pods -n cert-manager -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | uniq)
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[SETUP] requirements - Prepare Harbor manifests (externalIP)" {
    info
    files_to_change="""
    examples/full-harbor/kustomization.yaml
    examples/full-harbor/config/registry/config.yml
    examples/full-harbor/patch/ingress.yml
    examples/full-harbor/secrets/notary/server.json
    """
    for file in ${files_to_change}
    do
        sed -i'' -e 's/%YOUR_DOMAIN%/'"${INSTANCE_IP}"'.sslip.io/g' ${file}
    done
}

@test "[SETUP] Harbor" {
    info
    install_harbor(){
        kustomize build examples/full-harbor | kubectl apply -f -
    }
    loop_it install_harbor 20 3
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[SETUP] Check Harbor" {
    info
    test(){
        status=$(kubectl get pods -n harbor -l app=harbor -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | uniq)
        if [ "${status}" != "true" ]
        then
            # Don't know why notary does not start at first try
            kubectl -n harbor patch deployment notary-server -p \ "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
            kubectl -n harbor patch deployment notary-signer -p \ "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
            return 1
        fi
    }
    loop_it test 10 30
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "[SETUP] Check Harbor certificates" {
    info
    test(){
        status=$(kubectl -n harbor get certs -o jsonpath='{range .items[*].status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}' | uniq)
        if [ "${status}" != "True" ]; then return 1; fi
    }
    loop_it test 30 3
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
