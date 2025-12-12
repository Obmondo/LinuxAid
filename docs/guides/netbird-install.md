# Netbird

## Setup Netbird Server

We've documented the process of setting up Netbird server via [Kubeaid Netbird](https://github.com/Obmondo/KubeAid/blob/master/argocd-helm-charts/netbird/README.md) helm chart.
It also includes keycloak configuration, making it easier to setup user accounts with ease.

Access the [Keycloak Admin Console](https://keycloak.example.com/auth/admin/master/console), change the realm, and then add users.

## Setup Netbird Client

> We've automated the Netbird installation on Linux using [LinuxAid](https://github.com/obmondo/linuxaid). For other operating systems you'll have to install Netbird client manually from [Netbird Github Releases](https://github.com/netbirdio/netbird/releases), and then use the configurations provided in [puppet netbird](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/manifests/network/netbird.pp).

All the configurations required for setting up Netbird client is documented in [Linuxaid Netbird References](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md#common--network--netbird).

### Prerequisites

- A linux server/machine with root user access.
- Linuxaid installed and configured on your server/machine.

### The Updated Approach (using Obmondo UI)

1. Login to Obmondo, and go to servers page.
2. Click on your server, and click on "Configure".
3. An interactive UI wizard will pop-up, where you can configure the changes Linuxaid offers.
4. Go to `common::network::netbird` to see all the available options.
5. Enable netbird, provide the server url, and setup key.
6. Verify the changes made, and then click on Apply.
7. Our engineers will be notified of this change, and once reviewed, the change will be live.

### The Manual Approach

Configure your server/machine in `linuxaid-config` to enable netbird client installation

my-machine.yaml

    ```yaml
    common::network::netbird::enable: false
    common::network::netbird::server: https://vpn.example.com
    common::network::netbird::setup_key: <encrypted setup key using hiera-eyaml>

    # Optionally, you can specify the specific netbird client version with the checksum. By default, Linuxaid maintains a stable version of netbird client, and updates them on regular basis.
    common::network::netbird::version: 0.59.3
    common::network::netbird::checksums:
      0.59.3: 1a251bfecd6ffbe633bc985e382b12efb1f5b5bd9ec8c2543b5cfa7d7ce4070a
      0.60.0: 0774801213f95392684efe3f13b746bab0f633b3546b9063860b073fe153c6e4
    ```

### Verifying Netbird Installation

1. Puppet/Openvox will fetch the updated changes in a while
2. Check if the netbird client is installed and is configured correctly.

        ```sh
        # Optionally you can pass -d flag for more information
        netbird status
        ```
3. Access the [Netbird Server](https://vpn.example.com) and verify if your machine is listed in the connected peers.
