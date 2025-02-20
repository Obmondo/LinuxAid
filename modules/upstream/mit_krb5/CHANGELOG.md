#### 2021-10-29 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.4.0

##### New features

* Add support for `plugins` (See [#28](https://github.com/ccin2p3/puppet-mit_krb5/pull/28))

#### 2021-09-22 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.3.1

##### Dependencies

* Relax puppet version requirements (Fixes [#27](https://github.com/ccin2p3/puppet-mit_krb5/issues/27))

#### 2021-09-22 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.3.0

##### New features

* Add support for `pkinit_anchors` and `spake_preauth_groups` (See [#25](https://github.com/ccin2p3/puppet-mit_krb5/pull/25))
* Add support for `http_anchors` (See [#23](https://github.com/ccin2p3/puppet-mit_krb5/pull/23))

##### Dependencies

* Now requires [ccin2p3-etc_services](https://forge.puppet.com/modules/ccin2p3/etc_services) module in version 2.x
* This module has been tested with puppetlabs-concat version `7.1.1`
* This module has been tested with puppetlabs-stdlib version `8.0.0`

#### 2019-06-12 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.2.1

##### Fixes
* Add support for Array values in realm `auth_to_local` param (See [#24](https://github.com/ccin2p3/puppet-mit_krb5/issues/24))

#### 2019-06-11 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.2.0

##### New features
* Add support for rotating KDCs using `fqdn_rotate` function (See [#22](https://github.com/ccin2p3/puppet-mit_krb5/pull/22))

#### 2018-09-21 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.1.1

##### Fixes
* Make `appdefaults` accept boolean values (See [#21](https://github.com/ccin2p3/puppet-mit_krb5/issues/21))

#### 2018-09-20 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.1.0

##### New features
* Add support for `dns_canonicalize_hostname` in `libdefaults` section (See [#19](https://github.com/ccin2p3/puppet-mit_krb5/pull/19))
* Add support for `pkinit_pool` in `mit_krb5::realm` defined type (See [#18](https://github.com/ccin2p3/puppet-mit_krb5/pull/18))
* Add native _hiera_ integration with automatic creations of `mit_krb5::domain_realm`, `mit_krb5::capaths̀`, `mit_krb5::appdefaults̀`, `mit_krb5::realm` and `mit_krb5::dbmodules` resource types using _hiera_ (See [#20](https://github.com/ccin2p3/puppet-mit_krb5/issues/20))

#### 2018-09-05 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.0.0

##### New features
* Add support for `dbmodules` section (See [#14](https://github.com/ccin2p3/puppet-mit_krb5/pull/14))
* Add support for `include`, `includedir` and `module` parameters in `libdefaults` section (See [#15](https://github.com/ccin2p3/puppet-mit_krb5/pull/15))
* Add support for `master_kdc` in `realm` section (See [#16](https://github.com/ccin2p3/puppet-mit_krb5/pull/16))

##### Breaking changes
* Use Puppet v4 native data types
* Upgrade minimum `puppetlabs-stdlib` required version to `4.13.0`
* Upgrade minimum `puppetlabs-concat` required version to `1.1.0`

#### 2018-06-25 - Remi Ferrand <puppet@cc.in2p3.fr> - 0.4.1

* Migrate to PDK version `1.6.0`
* Introduce new dependency on `ccin2p3-etc_services`

##### Fixes
* Fixes `metadata.json` (See [#10](https://github.com/ccin2p3/puppet-mit_krb5/pull/10))

##### New features
* Add support for options `default_ccache_name` and `pkinit_anchors` (See [#11](https://github.com/ccin2p3/puppet-mit_krb5/pull/11))
* Add support for option ̀`canonicalize` (See [#7](https://github.com/ccin2p3/puppet-mit_krb5/pull/7))

#### 2016-03-31 - Fabien Wernli <puppet@cc.in2p3.fr> - 0.2.1

* add compatibility with concat 2.x

#### 2014-10-31 - Remi Ferrand <puppet@cc.in2p3.fr> - 0.1.0
##### History
This Puppet module was originaly created by Patrick Mooney (https://github.com/pfmooney/puppet-mit_krb5). The module was forked by CC-IN2P3 because P. Mooney couldn't provide active support anylonger.
##### New features
* Add `appdefaults` section (https://github.com/pfmooney/puppet-mit_krb5/pull/3)
* Add `v4_name_convert` and `kpasswd_server` support in _[realm]_ section (https://github.com/pfmooney/puppet-mit_krb5/pull/3)
