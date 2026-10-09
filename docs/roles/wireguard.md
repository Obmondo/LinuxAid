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

3. Add the peer to the server's tunnel in hiera (see the example in step 8).
   The server's `allowed_ips` for a peer lists only what sits behind that
   peer: its tunnel address, plus any network it routes for. Do not copy the
   client's own `AllowedIPs` here. WireGuard hands a range to one peer only
   (the last one listed wins).

4. Run puppet on the server. systemd-networkd owns the tunnel interface;
   puppet recreates it from the new config, so connected clients drop for a
   few seconds and reconnect. There is nothing to restart by hand.

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

7. Check if wg is working

    ```sh
    sudo wg
    ```

8. Example hiera setup

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
