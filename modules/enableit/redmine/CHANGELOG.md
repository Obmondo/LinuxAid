##2.3.0
WARNING: With the next major version (3.0.0) we will up the default redmine version.
Check if you can upgrade to 2.6.x or explicitly set your version.
Now passenger starts redmine on apache start. This removes the delay the first
visitor experiences after a restart of the webserver.

###Features
- Start a passenger worker for redmine when apache starts

##2.2.0

###Notes
This version improves the experience for users who just want to get redmine working
out of the box without much configuration.
For those of you who already have a vhost set up and want to get redmine running in
a subdirectory, we have a new `www_subdir` setting.
Ubuntu 10.04 support has been dropped because it has been deemed too old.

###Features
- Option to install redmine in a directory relative to the webroot
- CentOS support

###Bugfixes
- Set the webroot correctly on non Redhat based systems
- Added note on requiring EPEL
- Log file rotation now uses the install dir and not the symlink

##2.1.0

###Notes
You can now manage your redmine plugins with the newly added `redmine::plugin` type. All
standard actions such as installing, updating and removing are supported.
This release deprecates wget. It will be removed in the next major version. Please use a
version control system like git instead.

###Features
- Deprecate wget provider
- Added support for plugins
- Ubuntu 14.04 (trusty) support

###Bugfixes
- Specify gem versions for tests
- Fix unbound dependency versions
- Fixes to the wget provider
- Fix evaluation error in Puppet 4

##2.0.0

###Features
- Automaticially install the correct VCS provider
- Detect ruby version and set database adapter accordingly

##1.2.1

###Features
- Improved Metadata quality

##1.2.0

###Notes
This release fixes some dependency races that could occur because some requires where missing.
Additionally, postgresql can now be selected as the database adapter.

###Features
- Postgresql support

###Bugfixes
- Require all packages before doing install
- Fix MySQL dependency order

##1.1.0

###Features
- Added debian support
- Custom configuration options
- Add ImageMagick to debian

##1.0.1

###Bugfixes
- Fixed whitespace in documentation

##1.0.0

###Notes
With rubyforge no longer available, the module now downloads redmine from the official repos
or from a user provided url.

###Features
- Added VCS support
- Git is now the default provider
- Added download url to the options
- Added metadata.json
- Tests now include linting and syntax checking
- Run redmine updates
- Support for mariadb

###Bugfixes
- Removed deletion of the default apache site
- Fix dependencies for debian
- Fix file permissions
