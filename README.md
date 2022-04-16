Using
---
### Fedora
```sh
$ packer build -var="os_version=35" fedora/fedora.pkr.hcl
$ vagrant box add build/fedora/35/x86_64/manifest.json
$ vagrant up fedora
```

### OpenBSD
```sh
$ packer build -var="os_version=7.0" openbsd/openbsd.pkr.hcl
$ vagrant box add build/openbsd/7.0/amd64/manifest.json
$ vagrant up openbsd
```
