### Wireguard client setup

1. Install Wireguard locally if you don't have it already.

   ```sh
   # Ubuntu
   apt-get install wireguard

   # MacOS
   brew install wireguard-tools
   ```

2. Configure your client wg config by creating the public and private key

   ```sh
   wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
   ```

3. Access your wireguard server instance via ssh.

   ```sh
   # ssh username@wg.<domain-name>

   # sudo -i

   # vim /etc/wireguard/wg0.conf

   # Add the peer block like this
   [Peer]
   # friendly name of the peer
   Publickey = <Public Key from above command>
   AllowedIPs = <IP Address of the client>/<Subnet which you would like the wg-client can access to>
   ```

4. Restart wg interface when we setup for first time on any server

   ```sh
   systemctl restart wg-quick@wg0.service
   ```

5. On your workstation

   ```sh
   # cat /etc/wireguard/wg0.conf


   [Interface]
   PrivateKey = <Private Key from above command>
   Address = <IP Address of the client>
   DNS = <DNS IP> # This would be diff based on CIDR of the kubernetes cluster

   [Peer]
   PublicKey = <Public key of the wireguard server> # Obmondo will share this to you
   Endpoint  = <public-ip>:<wg-port> # wg.<domain-name>:51820
   AllowedIPs = <CIDR of the kubernetes cluster>
   PersistentKeepalive = 25
   ```

6. Start wg on your client

   ```sh
   sudo wg-quick up wg0
   ```

7. Reload wg when we add a new peer

   ```sh
   wg syncconf wg0 <(wg-quick strip wg0)
   ```

8. Check if wg is working

    ```sh
    sudo wg
    ```

9. Example hiera setup

  ```yaml
  common::network::wireguard::enable: true
  common::network::wireguard::tunnels:
    wg0:
      private_key: your-private-key
      listen_port: 123
      address: '10.1.20.1/24'
      peers:
        -
          Comment: client1
          PublicKey: your-client1-pub-key
          AllowedIPs: '10.1.20.197/32, 10.10.10.0/24'
          Endpoint: 10.10.10.2:44222
          PersistentKeepalive: 10
        -
          Comment: client2
          PublicKey: your-client2-pub-key
          AllowedIPs: '10.1.20.198/32'
          Endpoint: 10.10.10.1:44223
          PersistentKeepalive: 10
  ```

### Wireguard server notes

* Tunnels with `manage_config: true` (the default) use the `wgquick` provider. Puppet writes
  `/etc/wireguard/<tunnel>.conf` and keeps `wg-quick@<tunnel>.service` enabled and running.
  A change to the tunnel config restarts the service, so active clients reconnect within a few seconds.

* Hosts that were first set up with the `systemd` provider still carry
  `/etc/systemd/network/<tunnel>.netdev` and `<tunnel>.network`. With those in place systemd-networkd
  creates the interface at boot, without an address, and `wg-quick` fails because the interface already
  exists. The tunnel then handshakes but forwards nothing. Puppet removes both files and the interface
  networkd created, then starts `wg-quick`.

* On the server, a peer's `allowed_ips` lists only what sits behind that peer: its tunnel address and any
  network it routes for. Do not copy the client's own `AllowedIPs` here. WireGuard hands a range to one
  peer only (the last one listed wins) and `wg-quick` routes every listed range into the tunnel.
