# Fury Kubernetes Registry

This repository contains all components necessary to deploy a container registry on top of Kubernetes.

## Registry Packages

The following packages are included in the Fury Kubernetes Registry Katalog.

- [harbor](katalog/harbor): Harbor is an open-source container image registry that secures images with role-based
access control, scans images for vulnerabilities, and signs images as trusted. Version: **2.2.2**

## Requirements

All packages in this repository have the following dependencies, for package
specific dependencies, please visit the single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.18.0`
- [Furyctl](https://github.com/sighupio/furyctl) package manager to download
  Fury packages >= [`v0.2.2`](https://github.com/sighupio/furyctl/releases/tag/v0.2.2)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) >= `v3.10.0`

## Compatibility

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       |       1.21.X       |
| ----------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| v1.0.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.0.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.1.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.1.1                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.1.2                              |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.2.0                              |                    |                    |                    |                    |     :warning:      |     :warning:      |     :warning:      |     :warning:      |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible

### Warning while upgrading from 1.X to 1.2

If you are using notary in your Harbor setup and you updated the setup from 1.x to 1.2 you 
could hit the following [issue](https://github.com/goharbor/harbor/issues/14932).


## Examples

To see examples on how to customize Fury Kubernetes Registry packages, please
go to [examples](examples) directory.

## Documentation

If you want to read the entire documentation including usage examples, feel free to read it in
the [Kubernetes Fury Distribution documentation site](https://kubernetesfury.com/docs/modules/registry/)

## License

For license details, please see [LICENSE](LICENSE)
