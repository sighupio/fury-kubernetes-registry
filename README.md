# Fury Kubernetes Registry

This repository contains all components necessary to deploy a container registry on top of Kubernetes.

## Registry Packages

The following packages are included in Fury Kubernetes Registry katalog.

- [harbor](katalog/harbor): Harbor is an open-source container image registry that secures images with role-based
access control, scans images for vulnerabilities, and signs images as trusted. Version: **2.0.0**

## Requirements

All packages in this repository have following dependencies, for package
specific dependencies, please visit the single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.14.0`
- [Furyctl](https://github.com/sighupio/furyctl) package manager to download
  Fury packages >= [`v0.2.2`](https://github.com/sighupio/furyctl/releases/tag/v0.2.2)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) >= `v3.3.0`

## Compatibility

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |
| ----------------------------------- | :----------------: | :----------------: | :----------------: |
| v1.0.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.0.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible

## Examples

To see examples on how to customize Fury Kubernetes Registry packages, please
go to [examples](examples) directory.

## Documentation

If you want to read the entire documentation including usage examples, feel free to read it in
the [Kubernetes Fury Distribution documentation site](https://kubernetesfury.com/docs/modules/registry/)

## License

For license details, please see [LICENSE](LICENSE)
