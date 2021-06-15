# Harbor

## What is Harbor?

> Harbor is an open-source container image registry that secures images with role-based access control, scans images
> for vulnerabilities, and signs images as trusted. As a CNCF Incubating project, Harbor delivers compliance,
> performance, and interoperability to help you consistently and securely manage images across cloud-native compute
> platforms like Kubernetes and Docker.

*source: [goharbor.io](https://goharbor.io/)*

## Image repository and tag

* Harbor images from [dockerhub](https://hub.docker.com/u/goharbor):
  * goharbor/chartmuseum-photon:v2.2.2
  * goharbor/clair-photon:v2.2.2
  * goharbor/clair-adapter-photon:v2.2.2
  * goharbor/trivy-adapter-photon:v2.2.2
  * goharbor/harbor-core:v2.2.2
  * goharbor/harbor-db:v2.2.2
  * goharbor/harbor-jobservice:v2.2.2
  * goharbor/notary-server-photon:v2.2.2
  * goharbor/notary-signer-photon:v2.2.2
  * goharbor/harbor-portal:v2.2.2
  * goharbor/redis-photon:v2.2.2
  * goharbor/registry-photon:v2.2.2
  * goharbor/harbor-registryctl:v2.2.2
* Harbor repository: [https://github.com/goharbor/harbor](https://github.com/goharbor/harbor)

## Distributions

* [full-harbor](distributions/full-harbor):
  * All components deployed together without external dependencies.
  * Requires a default storage class configured as all the components rely on persistent volumes to store data.
  * Requires cert-manager and ingress controller
  * Only tested against public endpoints with valid certificates.
  * Uses Clair as default interrogation service
* [full-harbor-with-trivy](distributions/full-harbor-with-trivy):
  * All components deployed together without external dependencies.
  * Requires a default storage class configured as all the components rely on persistent volumes to store data.
  * Requires cert-manager and ingress controller
  * Only tested against public endpoints with valid certificates.
  * Uses Trivy as default interrogation service

## License

For license details please see [LICENSE](../../LICENSE)
