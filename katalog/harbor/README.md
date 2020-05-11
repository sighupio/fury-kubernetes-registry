# Harbor

## What is Harbor?

> Harbor is an open source container image registry that secures images with role-based access control, scans images
> for vulnerabilities, and signs images as trusted. As a CNCF Incubating project, Harbor delivers compliance,
> performance, and interoperability to help you consistently and securely manage images across cloud native compute
> platforms like Kubernetes and Docker.

*source: [goharbor.io](https://goharbor.io/)*

## Image repository and tag

* Harbor images from [dockerhub](https://hub.docker.com/u/goharbor):
  * goharbor/chartmuseum-photon
  * goharbor/clair-photon
  * goharbor/clair-adapter-photon
  * goharbor/harbor-core
  * goharbor/harbor-db
  * goharbor/harbor-jobservice
  * goharbor/notary-server-photon
  * goharbor/notary-signer-photon
  * goharbor/harbor-portal
  * goharbor/redis-photon
  * goharbor/registry-photon
  * goharbor/harbor-registryctl
* Harbor repository: https://github.com/goharbor/harbor

## Distributions

* [full-harbor](distributions/full-harbor):
  * All components deployed together without external dependencies.
  * Requires a default storage class configured as all the components rely on persistent volumes to store data.
  * Requires cert-manager and ingress controller
  * Only tested against public endpoints with valid certificates.

## License

For license details please see [LICENSE](../../LICENSE)
