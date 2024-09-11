# Changelog

All notable changes to this project will be documented in this file.

## Release 2.1.0

**Features**
Add suse support

## Release 2.0.1

**Bugfixes**
- Permit passing `undef` to vnc server parameters

## Release 2.0.0

**Breaking Change**
- Ports less than 100 passed to websockify will be prefixed with `59`

**Features**
- Added class to directly export VNC Servers to novnc/websockify

## Release 1.2.0

**Features**
- Added flag for setting config mode

## Release 1.1.0

**Features**
- Added switch for dynamic users under websockify service
- Note compat with puppet-systemd 6.x

## Release 1.0.2

**Features**
- Note puppet8 support

## Release 1.0.1

**Features**
- Note stdlib 9.x.x support

## Release 1.0.0

**Breaking Change**
Switch to stdlib::crc32, requires stdlib >= 8.6.0

## Release 0.4.0

**Bugfixes**
- Polkit tends to like world readable policy files.

## Release 0.3.3

**Bugfixes**
- fix typo in vncpasswd

## Release 0.3.2

**Bugfixes**
- fix template output when comments are missing

## Release 0.3.1

**Features**
- Added global param to set default for user managed services

## Release 0.3.0

**Features**
- Ability to not make ~/.vnc dirs per user
- Ability to not make ~/.vnc dirs in general

## Release 0.2.1

**Features**
- Note compatibility with puppet/systemd 4.x.x

## Release 0.2.0

**Features**
- Added minimal novnc support (just websockify really)

## Release 0.1.2

**Bugfixes**
- Typo in homedir search

## Release 0.1.1

**Bugfixes**
- Some template values had extra `=`

## Release 0.1.0

**Features**
Initial Release

**Roadmap**
- Add a novnc option

**Bugfixes**

**Known Issues**
