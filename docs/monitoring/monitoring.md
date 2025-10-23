# LinuxAid Monitoring

## Kube Prometheus Stack

**Grafana**

* URL: grafana-linuxaid.your-domain.io
* Login defaults to these, you can change it in the helm values file.
    user: root
    password: secretroot

**Prometheus**

* URL: prometheus-linuxaid.your-domain.io
* Alerts are written [here](https://github.com/Obmondo/kubeaid/tree/master/argocd-helm-charts/prometheus-linuxaid/rules)

**Alertmanager**

* URL: alertmanager-linuxaid.your-domain.io

## Exporters

* [Node](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporternode)
* [Blackbox](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterblackbox)
* [Cadvisor](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportercadvisor)
* [Dellhw](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterdellhw)
* [Dns](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterdns)
* [Elasticsearch](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterelasticsearch)
* [Filestat](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterfilestat)
* [Gitlab_runner](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportergitlab_runner)
* [Haproxy](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterhaproxy)
* [Iptables](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporteriptables)
* [Mtail](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportermtail)
* [Mysql](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportermysql)
* [Lsof](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporternodelsof)
* [Smartmon](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporternodesmartmon)
* [Ssacli](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporternodessacli)
* [Topprocesses](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporternodetopprocesses)
* [Ntp](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterntp)
* [Process](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterprocess)
* [Security](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportersecurity)
* [Systemd](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportersystemd)
* [Tcpshaker](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexportertcpshaker)
* [Wireguard](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#commonmonitorexporterwireguard)

## Monitoring

* Linuxaid comes with default monitoring exporter, which will be deployed on all the linux servers.

  ```raw
  * node exporter
  * dns exporter
  * iptables exporter
  * systemd exporter
  * mtail exporter
  * process exporter
  ```

* Exporter like cadvisor, haproxy will be loaded if the respective roles is selected or enabled manually via hiera file

  ```yaml
  common::monitor::exporter::security::enable: true
  ```

  or

  ```yaml
  common::monitor::exporter::filestat::enable: true
  common::monitor::exporter::filestat::file_pattern:
    - mysql_backup_mysql_*.sql.gz
    - mysql_backup_oauth_*.sql.gz
    - mysql_backup_saml*.sql.gz
  ```

* All these exporter are available as rpm and deb packages on [repo server](https://repos.obmondo.com/packagesign/public/)


### NOTES:

* This document expect that you have deployed the kube-prometheus stack using [prometheus-linuxaid](https://github.com/Obmondo/kubeaid/tree/master/argocd-helm-charts/prometheus-linuxaid)
