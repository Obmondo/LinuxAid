# This is the login-module configuration for a security domain
# Multiple login-modules can be specified for a single security domain.
#
# [*domain_name*]
#  Name of the security domain to be created on the Wildfly server.
#
# [*code*]
#  Login module code to use. See: https://docs.jboss.org/author/display/WFLY9/Authentication+Modules
#
# [*flag*]
#  The flag controls how the module participates in the overall procedure. Allowed values are:
#  `requisite`, `required`, `sufficient` or `optional`. Default: `required`.
#
# [*module_options*]
#  A hash of module options containing name/value pairs. E.g.:
#  `{ 'name1' => 'value1', 'name2' => 'value2' }`
#  or in Hiera:
#  ```
#   module_options:
#    name1: value1
#    name2: value2
#  ```
#
define wildfly::security::login_module($domain, $code, $flag, $module_options={}) {

  wildfly::util::resource { "/subsystem=security/security-domain=${domain}/authentication=classic/login-module=${code}":
    content => {
      'code'           => $code,
      'flag'           => $flag,
      'module-options' => $module_options,
    },
  }

}