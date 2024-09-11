# This is a defined resource type for creating a security domain
# Please also see: https://docs.jboss.org/author/display/WFLY9/Security+subsystem+configuration
#
# [*domain_name*]
#  Name of the security domain to be created on the Wildfly server.
#
# [*login_modules*]
#  A hash with a specification of all login-modules to add to the domain.
#  Also see the documentation of `wildfly::security::login_module`
#  Example:
#    { 'login-module-1' => {
#        domain_name => 'my-security-domain',
#        code => 'DirectDomain',
#        flag => 'required',
#        module_options => { realm => 'my-security-realm' }
#      },
#      'login-module-2' => {
#        ...
#      }
#    }
#
define wildfly::security::domain(
  $domain_name   = $title,
  $login_modules = {}
) {

  wildfly::util::resource { "/subsystem=security/security-domain=${domain_name}":
    content => {
      'cache-type' => 'default',
    },
  } ->

  wildfly::util::resource { "/subsystem=security/security-domain=${domain_name}/authentication=classic":
    content => {},
  }

  create_resources('wildfly::security::login_module', $login_modules)

  Wildfly::Util::Resource[ "/subsystem=security/security-domain=${domain_name}/authentication=classic"] ->
    Wildfly::Security::Login_module<|tag == 'wildfly'|>

}