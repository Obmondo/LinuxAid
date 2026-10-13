# NAT Gateway

Turn a host into the internet exit for a private network: machines that only have a private
address send their outbound traffic to this host, and it forwards it under its own public address.

## Enable it

Set this in the host's hiera file:

```yaml
common::network::nat_gateway::enable: true
```

That is enough for a host with one public and one private interface. It does not need full host
management.

If the host runs in noop mode, the change is only reported until you also set:

```yaml
common::network::nat_gateway::noop_value: false
```

Two optional settings narrow it down:

```yaml
# Only masquerade these networks. Default: everything leaving the public interface.
common::network::nat_gateway::source:
  - 10.0.0.0/16

# Interface the traffic leaves through. Default: the interface of the default route.
common::network::nat_gateway::out_interface: eth0
```

## What LinuxAid does

- Sets `net.ipv4.ip_forward = 1` in `/etc/sysctl.d/net.ipv4.ip_forward.conf` and applies it.
- Adds a `MASQUERADE` rule to the `nat` table, chain `POSTROUTING`, for the outgoing interface.
- Saves the rule so it is loaded again at boot. On Debian and Ubuntu this installs
  `iptables-persistent` and enables `netfilter-persistent`; apt removes `ufw` because the two conflict.

When the LinuxAid firewall is managed on the host (`common::network::firewall::enable` and
`common::network::firewall::manage`), forwarding is allowed there automatically; you do not need to
set `common::network::firewall::enable_forwarding` as well.

## Limits

- IPv4 only.
- Without the managed firewall it works on the Debian family only. On other OS families the catalog
  fails with a message asking for the managed firewall, because the stock rule set of the iptables
  service rejects forwarded traffic there.
- Without the managed firewall the `FORWARD` chain policy has to be `ACCEPT`, which is the default.
- Setting `enable` back to `false` stops managing the rule and the sysctl. It does not remove them.

## Check it

On the gateway:

```sh
sysctl net.ipv4.ip_forward              # 1
iptables -t nat -S POSTROUTING          # shows the MASQUERADE rule
grep MASQUERADE /etc/iptables/rules.v4  # the rule is saved (Debian family)
```

Reboot once and run the first two commands again: both must still be in place.

A hand-made rule for the same network stays next to the managed one. It is harmless, but you can
remove it once the managed rule is there:

```sh
iptables -t nat -D POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE
netfilter-persistent save
```
