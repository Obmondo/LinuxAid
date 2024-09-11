# vnc

Manage tigervnc now that it expects systemd-logind support.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with vnc](#setup)
    * [What vnc affects](#what-vnc-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with vnc](#beginning-with-vnc)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module manages VNC servers utilizing the new tigervnc scripts
from tigervnc 1.11 and later.

Users can optionally be given rights to restart their own servers.

## Setup

### What vnc affects

This will impact your VNC sessions, configs in /etc/tigervnc (parameter),
and PolicyKit for systemd (if user restart is granted via the params).

If requested the `vnc::client::novnc` will try to setup the non-webserver
parts of a noVNC site.

### Setup Requirements **OPTIONAL**

If you wish to use the novnc client, you must setup a webserver to point
at the websocket.



### Beginning with vnc

## Usage

### Server
If the defaults are workable for you, basic usage is:

```puppet
class { 'vnc::server':
  manage_services => true,
  vnc_servers => {
    'userA' => {
       'comment' => 'Optional comment',
       'displaynumber' => 1,
       'user_can_manage' =>  true,
    }
}
```
Or via hiera
```yaml
vnc::server::manage_services: true
vnc::server::vnc_servers:
  userA:
    comment: Optional comment
    displaynumber: 1
    user_can_manage: true
```

The most interesting parameter is `vnc::server::vnc_servers`.

It has a structure of:

```yaml
username:
  comment: (optional) comment
  displaynumber: The VNC screen, like 1, 2, 3, etc
  ensure: service ensure, default is 'running'
  enable: service enable, default is 'true'
  seed_home_vnc: make ~${username}/.vnc/config, default is `vnc::server::seed_user_vnc_config`
  user_can_manage: Boolean value to permit a user to run `systemctl restart vncserver@:#.service`
                   where the `#` is their listed displaynumber.
                   default value is from $vnc::server::user_can_manage
```

For hosts where a users's home is on a kerberos protected volume, you'll
probably want to set `seed_home_vnc = false` as the puppet process will
not have access. Or globally via `vnc::server::seed_home_vnc`.

Similarly, when "user home" is not accessible to unauthenticated systemd,
you'll probably want to set `vnc::server::manage_services = false`.

You can directly export these sessions to noVNC via `include vnc::server::export::novnc`.

### Client
Similarly, VNC clients can be loaded with:

```puppet
class { 'vnc::client::gui': }
```

or

```puppet
class { 'vnc::client::novnc': }
```

The noVNC client takes a parameter `vnc_sessions` with a format of:
```yaml
vnc::client::novnc::vnc_servers:
  session_name: server:port
  other_session_name: server:otherport
```

By default token based configuration is used to let the webserver multiplex to a single `websockify` instance.
An example HTML list of configured sessions is written out to `vnc::client::novnc::webserver_vnc_index`.

## Limitations

This requires the systemd units from tigervnc 1.11+.

You must manage you own firewall settings.

There are too may ways folks may want to setup the webserver, so no attempt
is made here to provide hooks for the websockets proxy via `httpd` or `nginx`.

If you want to use the SSL wrapper for `websockify` you are responsible to
depoy the cert, key, CA, and set the parameters you need.

## Development

See the linked repo in `metadata.json`
