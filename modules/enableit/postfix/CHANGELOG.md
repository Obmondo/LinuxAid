#### 2016-02-02 - 0.3.4
* Expanded TLS and client-TLS directives (#28, @adamcstephens).
* Cosmetic cleanups to main.cf templates.
* Fix ordering of postfix::file resources (#18).
* Fix wrong smtps_content_filter parameter default (#32, @gwarf).
* Add support for smtp_generic_maps (#53, @KlavsKlavsen).
* Fix spampd options (#46, @chihoko).
* Add mailbox_size_limit.
* Allow mynetworks to also be an array.
* Allow inet_interfaces to also be an array.
* Change from Modulefile to metadata.json.

#### 2014-05-12 - 0.3.3
* Add Debian support for spampd (#26, @timogoebel).
* Content filter SMTPS, add more parameters (#27, @tjnicholas).

#### 2014-03-31 - 0.3.2
* Add FreeBSD support (#23, @fraenki).
* Add transport_maps, canonical_maps & relocated_maps (#24, @fraenki).

#### 2014-03-18 - 0.3.1
* Add extension support for dovecot+virtual users (#19, @winks).
* Add new TLS directives (#21, Steffen Zieger).

#### 2014-02-04 - 0.3.0
* Support a few more main.cf directives (#15, RedRampage).
* Add extra_main_parameters to support any extra main.cf directives.

#### 2013-10-28 - 0.2.4
* Add smtp client sasl auth configuration (aellert).
* Fix dovecot directory for Debian (Florian Anderiasch).
* Fix first run errors on master.cf and main.cf's parent directory (#12).
* Don't notify service when updating db files, it's useless (#14).

#### 2013-09-17 - 0.2.3
* Reverse the el5/el6 logic to have the RHEL6 templates be the default now.
* Update fallback_relay= to smtp_fallback_relay= in el5 master template (#4).
* Add support for changing the key/crt file location and names.

#### 2013-07-17 - 0.2.2
* Add setgid_group option in main.cf (Karsten Schöke).
* Update templates where @ variable prefixes were still missing.

#### 2013-07-08 - 0.2.1
* Add Debian osfamily support (Vadim Lebedev).
* Move service_restart to params to have only one osfamily conditional.

#### 2013-05-31 - 0.2.0
* Fix the leftover $title from where we had a definition.
* Update README and use markdown.
* Change to 2-space indent.

#### 2012-12-18 - 0.1.4
* Use el6 templates for CentOS too.
* Improve postfix::dbfile documentation.
* Fix postfix::dbfile absent by also removing the *.db file.
* Change postfix::server to be a parametrized class.
* Clean up postfix::file.
* Fix body_checks template generation.

#### 2012-04-04 - 0.1.3
* Add smtpd_sasl_auth support for dovecot auth.
* Make spampd more configurable.
* Add support for header_checks lines.
* Enhance support for local dovecot delivery.
* Fix scope of used facts.

#### 2012-04-03 - 0.1.2
* Clean up the postfix module to match current puppetlabs guidelines.

