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
$ make destroy
```
