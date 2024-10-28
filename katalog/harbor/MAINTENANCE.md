# Development notes

## Harbor

Here is explained how we develop the Harbor package inside the registry SIGHUP module. It's essential to
maintain this document updated. So, any new/modified action has to be written here.

### Service monitor manifests

The service monitor manifests `katalog/harbor/exporter/sm.yml` file has been templated from:

- <https://github.com/goharbor/harbor-helm/blob/master/templates/metrics/metrics-svcmon.yaml>
- <https://goharbor.io/docs/2.7.0/administration/metrics/>

Once deployed, you will be able to find a `serviceMonitor` Prometheus Operator resources. It is required to allow prometheus to fetch the metrics exposed by Harbor

### Demos / Testing

All the following examples are tested in the pipeline

### e2e tests

- [setup](../../katalog/tests/harbor/setup.sh)
- [vulns](../../katalog/tests/harbor/vulns.sh)
- [chartmuseum](../../katalog/tests/harbor/chartmuseum.sh)
- [replication](../../katalog/tests/harbor/replication.sh)
- [registry](../../katalog/tests/harbor/registry.sh)
- [registry-notary](../../katalog/tests/harbor/registry-notary.sh)

### Dashboard and Rules

#### Grafana Dashboards

The Grafana dashboard found in `katalog/harbor/exporter/dashboards` was taken from:

- [Harbor Metrics](https://github.com/goharbor/harbor/blob/main/contrib/grafana-dashborad/metrics-example.json)

Compared to the official dashboards, the following changes have been made:

- renamed the variable from `DS_PROMETHEUS` to `datasource`
- added the `harbor` tag to the dashboards
- added "Legend" on all gadgets

#### Prometheus Rules

Harbor upstream does not provide a set of Prometheus Rules that we could include.
The Prometheus Rules defined in `katalog/harbor/exporter/rules.yml` are inspired by those provided by:
<https://promcat.io/apps/harbor>

Once deployed, you will be able to find some `Alert`s defined on the Prometheus dashboard.

To export the list of alerts from the YAML file to include them in the readme you can use the following command:

```bash
yq e '.spec.groups[] | .rules[] |  "| " + .alert + " | " + (.annotations.summary // "-" | sub("\n",". "))+ " | " + (.annotations.description // "-" | sub("\n",". ")) + " |"' katalog/harbor/exporter/rules.yml
```

### Trivy Database Update Offline

The trivy configuration has been updated to download the new image with the updated vulnerability database every night. To do this we have added: [an image that is built every night](https://github.com/sighupio/trivy-adapter-photon-offline), an ad-hoc rbac and a cronjob to restart the pod. The new image is downloaded from the following [repository](https://quay.io/repository/sighup/trivy-adapter-photon-offline?tab=tags).