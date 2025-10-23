# LinuxAid Agent

## Setup

* Install [Puppet agent](https://help.puppet.com/core/current/Content/PuppetCore/install_nix_agents.htm)

```
# Redhat
sudo yum install puppet-agent

# Debian
sudo apt-get install puppet-agent
```

* Setup puppet.conf

```
cat /etc/puppetlabs/puppet/puppet.conf
[main]
  server = <puppetserver.url>
  certname = <certname>
  masterport = 8140
  environment = production
  runinterval = 30m
  strict_variables = true
  manage_internal_file_permissions = false
  runtimeout = 20m

[agent]
report = true
noop = false
graph = true
splaylimit = 60s
splay = true
```

* Run puppet agent

```
puppet agent -t --noop
```
