# fury-kubernetes-registry

## Improvements

- External DB
- External Cache 
- Object Storage for:
  - Registry
  - ChartMuseum
- Object Storage:
  - Local (minio)
  - External (cloud)

## Developer notes

```bash
$ export repo_path=$(pwd)
$ echo ${repo_path}
/Users/angelbarrerasanchez-sighup/work/sighup/fury-kubernetes-registry
$ cd /Users/angelbarrerasanchez-sighup/work/sighup/e2e-testing/cloud
$ LOCAL_KIND_CONFIG_PATH=${repo_path}/katalog/tests/config/kind-harbor-config CLUSTER_VERSION=1.16.4 make init custom-cluster-116

```

Remember to deploy cert-manager and nginx

```bash
$ cd ${repo_path}/katalog/tests/config
$ furyctl vendor -H
$ kustomize build | kubectl apply -f -
```

```bash
$ cd ${repo_path}
$ kustomize build katalog/harbor/examples/full-harbor/ | kubectl apply -f -
```

```bash
$ make destroy
```

Helm

```bash
apt-get update && apt-get install -y curl ca-certificates git
curl -LOs https://get.helm.sh/helm-v2.16.7-linux-amd64.tar.gz
tar -zxvf helm-v2.16.7-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf helm-v2.16.7-linux-amd64.tar.gz
helm init --client-only
helm plugin install https://github.com/chartmuseum/helm-push
helm fetch stable/nginx-ingress --version 1.36.2
helm repo add --username=admin --password=Harbor12345 harbor-test https://harbor.3.249.106.50.nip.io/chartrepo/library
helm push --username=admin --password=Harbor12345 nginx-ingress-1.36.2.tgz harbor-test
```
