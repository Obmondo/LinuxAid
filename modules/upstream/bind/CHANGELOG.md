#### 2025-06-18 - 0.5.8
* Remove obsolete dnssec-enable and dnssec-lookaside options.
* Change dnssec-validation to its current upstream default of 'auto', which
  might actually enable it since 'yes' required keys and trust anchors.
* Remove RHEL 5 and 6 support, those had older bind 9 with different dnssec.

#### 2025-02-04 - 0.5.7
* Remove legacy facts usage.

#### 2023-09-07 - 0.5.6
* Change zone dirmode from 750 to 770 because recent bind 9 requires write.

#### 2021-06-30 - 0.5.5
* Improve zone validation (#110, @osgpcq).
* Support $replace on bind::server::file, useful for ddns base zones.
* Fix bindkeys-file on RHEL8.

#### 2019-01-21 - 0.5.4
* Add zone file validation (#91, @forgodssake).
* Fix hint and rfc1912 zones on Debian (#61, #83).
* Add support for configuring forward mode (#73, @warrenpnz).
* Fix server::conf and package ordering (#71, @skrivy).
* Make sure zonedir gets created after bind::package (#55, @jamesbouressa).

#### 2017-02-02 - 0.5.3
* Fix undefined variable warning.

#### 2016-02-02 - 0.5.2
* Fix service name on RHEL7+ with chroot (#56, @arrjay).
* Fix named.conf template bug related to views (#59, @imerali).
* Add TSIG keys support (#54, @b4ldr).
* Replace Modulefile with metadata.json.

#### 2014-05-12 - 0.5.1
* Add FreeBSD support (#26, @fessoga5).

#### 2014-03-14 - 0.5.0
* Manage zonedir from server::file, for parent directory (#23, Dougal Scott).
* Add support for extra_options (#22, Joseph Swick).
* Add support for $hostname, $server_id (#21, @b4ldr).
* Disable root hint and rfc1912 zones when not recursive (#21, @b4ldr).

#### 2013-11-26 - 0.4.2
* Add support for managed-keys-directory (#19, Sean Edge).
* Add support for full service restart instead of reload (#19, Sean Edge).

#### 2013-10-15 - 0.4.1
* Add support for views (thanks to Sean Edge).

#### 2013-07-17 - 0.4.0
* Merge changes by Sebastian Cole.
* Move parameters into a new bind::params class.
* Make the service and package classes possible to use separately.
* Cosmetic cleanups.
* Update README examples.

#### 2013-04-19 - 0.3.2
* Use @varname syntax in templates to silence puppet 3.2 warnings.

#### 2013-04-10 - 0.3.1
* Add support for $allow_transfer.
* Add support for $ensure on server::file, enabling clean zone file removal.

#### 2013-03-08 - 0.3.0
* Change to 2 space indent.
* Major update to the README and use markdown.
* Minor cosmetic cleanups.
* Change default for $chroot to false, SELinux is sufficient on RHEL5+.

#### 2012-12-18 - 0.2.5
* Change the SELinux type of the log directory back to the original.

#### 2012-09-19 - 0.2.4
* Update README to make the main example more useful.
* Support $source_base for easy inclusion of multiple zone files as-is.

#### 2012-07-17 - 0.2.3
* Add support for "include" lines in named.conf.

#### 2012-06-22 - 0.2.2
* Add support for a few new configuration values in the main template.
* Require package for files, for the usual parent directory to exist.
* Minot updates to the README.

#### 2012-04-23 - 0.2.1
* Clean up the module to match current puppetlabs guidelines.
* Force hash sorting in the template for puppet 2.7+ compatibility.

