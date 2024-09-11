# This defined resource configures a (opiniated!!) LDAP security realm.
#
# Based on (among others):
# - https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6/html/Development_Guide/Add_a_New_Security_Realm.html
# - https://docs.jboss.org/author/display/WFLY9/Security+Realms
# - https://docs.jboss.org/author/display/WFLY9/The+native+management+API
# - https://docs.jboss.org/author/display/WFLY9/Security+subsystem+configuration
# - http://wildscribe.github.io/Wildfly/9.0.0.Final/core-service/management/security-realm/index.html
#
#  The realm created is a security realm that can be associated with a management interface and used
#  to control access to the management and/or application services.
#  This LDAP security realm uses LDAP as the user repository to determine who is trying to log
#  in (authentication).
#  The authorization in this LDAP realm performs a group search in the LDAP server, where the group
#  entry contains an attribute referencing it's members (`member` attribute). A simple filter configuration
#  to identify the users distinguished name from their username is then used to create the mapping
#  between user and LDAP groups.
#  This configuration assumes the 'group-to-principal' and 'username-filter' to be used. Future versions
#  of this type might also allow 'principal-to-group' and 'advanced-filter'/'username-is-dn'. It does
#  *not* at this time. Also this module assumes the same type of cache to be used for both group and
#  username searches.
#
#  When using this security realm, you should also create group mappings in order to map
#  LDAP group names to the default Wildfly roles. See: `wildfly_wrapper::ldap_group_mapping`.
#
# [*ldap_url*]
#  URL to connect to the LDAP server. E.g.: 'ldap://ldap.my.org:389'
#
# [*ldap_search_dn*]
#  DN to use to connect to LDAP. E.g. 'uid=appserver,cn=users,ou=services,o=my,c=org'
#
# [*ldap_search_credential*]
#  Password (plain text) to use to connect to LDAP. This is the password for the
#  user specified in ldap_search_dn.
#
# [*ldap_user_base_dn*]
#  The context from where to start searching users. E.g. 'cn=users,ou=services,o=my,c=org'
#
# [*authorization_group_base_dn*]
#  The context from where to start searching for groups. E.g. 'cn=groups,ou=services,o=my,c=org'
#
# [*realm_name*]
#  The name of this LDAP Security Realm. Default: $title of this resource
#
# [*authentication_user_dn*]
#  The name of the attribute which is the user's distinguished name. Default: `dn`
#
# [*authentication_username_attribute*]
#  The name of the attribute to search for the user. This filter will then perform
#  a simple search where the username entered by the user matches the attribute specified here.
#
# [*authentication_username_load*]
#  The name of the attribute that should be loaded from the authenticated users LDAP entry to
#  replace the username that they supplied, e.g. convert an e-mail address to an ID or correct
#  the case entered. Default: `undef`
#
# [*authentication_recursive*]
#  Whether the search should be recursive. Default: `false`
#
# [*authentication_allow_empty_passwords*]
#  Should empty passwords be accepted from the user being authenticated. Default: `false`
#
# [*authorization_group_name*]
#  An enumeration to identify if groups should be referenced using a simple name or
#  their distinguished name. Defalt value: `SIMPLE`
#
# [*authorization_group_name_attribute*]
#  Which attribute on a group entry is it's simple name. Default: `cn`
#  When setting to `undef` the Wildfly default is used, which is: `uid`
#
# [*authorization_group_dn_attribute*]
#  Which attribute on a group entry is it's distinguished name. Default: `dn`
#
# [*authorization_group_search_by*]
#  Should searches be performed using simple names or distinguished names?
#  Default: `DISTINGUISHED_NAME`
#
# [*authorization_principal_attribute*]
#  The attribute on the group entry that references the principal.
#  Default value: `member`
#
# [*authorization_group_recursive*]
#  Should levels below the starting point be recursively searched?
#  Default: `true`. When setting to `undef` the Wildfly default will
#  be used which is: `false`
#
# [*authorization_group_iterative*]
#  Should further searches be performed to identify groups that the groups identified
#  are a member of (groups of groups)? Default: `false`
#
# [*authorization_prefer_original_conn*]
#  After following a referral should subsequent searches prefer the original connection
#  or use the connection of the last referral. Default: `true`
#
# [*authorization_user_name_attribute*]
#  The attribute on the user entry that is their username. Default: `uid`
#
# [*authorization_user_dn_attribute*]
#  The attribute on the user entry that contains their distinguished name.
#  Default value: `dn`
#
# [*authorization_user_force*]
#  Authentication may have already converted the username to a distinguished name,
#  force this to occur again before loading groups. Default: `false`
#
# [*authorization_user_recursive*]
#  Should levels below the starting point be recursively searched (e.g. sub ou's)?
#  Default: `false`
#
# [*apply_to_management_interface*]
#  Apply the created security realm to the Wildfly management interface?
#  Default: `false`
#
# [*cache_type*]
#  Defines which type of cache to use for previous username-filter results.
#  Valid values: `by-search-time` or `by-access-time`. Default: `by-access-time`.
#
# [*max_cache_size*]
#  The maximum size of the cache before the oldest items are removed to make room
#  for new entries. Default: `1000`
#  When setting to `undef` the Wildfly default will be used which is `0` (unlimited)
#
# [*cache_eviction_time*]
#  The time in seconds until an entry should be evicted from the cache. Default: `900`
#
# [*cache_failures*]
#  Should failures be cached? Default: `false`
#
define wildfly::security::ldap_realm(
  $ldap_url,
  $ldap_search_dn,
  $ldap_search_credential,
  $ldap_user_base_dn,
  $authorization_group_base_dn,
  $realm_name                           = $title,
  $authentication_user_dn               = undef,
  $authentication_username_attribute    = 'uid',
  $authentication_username_load         = undef,
  $authentication_recursive             = true,
  $authentication_allow_empty_passwords = false,
  $authorization_group_name             = 'SIMPLE',
  $authorization_group_name_attribute   = 'cn',
  $authorization_group_dn_attribute     = 'dn',
  $authorization_group_search_by        = 'DISTINGUISHED_NAME',
  $authorization_principal_attribute    = 'member',
  $authorization_group_recursive        = true,
  $authorization_group_iterative        = false,
  $authorization_prefer_original_conn   = true,
  $authorization_user_name_attribute    = 'uid',
  $authorization_user_dn_attribute      = 'dn',
  $authorization_user_force             = false,
  $authorization_user_recursive         = false,
  $apply_to_management_interface        = false,
  $cache_type                           = 'by-access-time',
  $max_cache_size                       = '1000',
  $cache_eviction_time                  = '900',
  $cache_failures                       = false,
) {

  # Create LDAP connectivity
  wildfly::util::resource { "/core-service=management/ldap-connection=${realm_name}-LDAPConnection":
    content => {
      'url'               => $ldap_url,
      'search-dn'         => $ldap_search_dn,
      'search-credential' => $ldap_search_credential,
    },
  } ->

  # Define the security realm
  wildfly::util::resource { "/core-service=management/security-realm=${realm_name}":
    content => {},
  } ->

  # Make sure the 'properties' authentication method is removed. Only 1 authentication method
  # is allowed in a security realm at one time
  wildfly::util::resource { "/core-service=management/security-realm=${realm_name}/authentication=properties":
    ensure  => absent,
    content => {},
  } ->

  # Bypass LDAP authentication when accessing management interface locally
  wildfly::util::resource { "/core-service=management/security-realm=${realm_name}/authentication=local":
    content => {
      'default-user'       => '$local',
      'skip-group-loading' => true,
    },
  } ->

  # Specify LDAP authentication for the security realm
  wildfly::util::resource { "/core-service=management/security-realm=${realm_name}/authentication=ldap":
    content => {
      'connection'            => "${realm_name}-LDAPConnection",
      'base-dn'               => $ldap_user_base_dn,
      'user-dn'               => $authentication_user_dn,
      'username-attribute'    => $authentication_username_attribute,
      'username-load'         => $authentication_username_load,
      'recursive'             => $authentication_recursive,
      'allow-empty-passwords' => $authentication_allow_empty_passwords,
    },
  } ->

  # Configure the LDAP parameters so it can find the groups a user belongs to
  # lint:ignore:arrow_alignment
  wildfly::util::resource { "/core-service=management/security-realm=${realm_name}/authorization=ldap":
    recursive => true,
    content   => {
      'connection'     => "${realm_name}-LDAPConnection",
      'group-search'   => {
        'group-to-principal' => {
          'group-name'                 => $authorization_group_name,
          'group-name-attribute'       => $authorization_group_name_attribute,
          'group-dn-attribute'         => $authorization_group_dn_attribute,
          'base-dn'                    => $authorization_group_base_dn,
          'search-by'                  => $authorization_group_search_by,
          'principal-attribute'        => $authorization_principal_attribute,
          'recursive'                  => $authorization_group_recursive,
          'iterative'                  => $authorization_group_iterative,
          'prefer-original-connection' => $authorization_prefer_original_conn,
          'cache'                      => {
            "${cache_type}" => {
              'max-cache-size' => $max_cache_size,
              'eviction-time'  => $cache_eviction_time,
              'cache-failures' => $cache_failures,
      }}}},
      'username-to-dn' => {
        'username-filter' => {
          'base-dn'           => $ldap_user_base_dn,
          'attribute'         => $authorization_user_name_attribute,
          'user-dn-attribute' => $authorization_user_dn_attribute,
          'force'             => $authorization_user_force,
          'recursive'         => $authorization_user_recursive,
          'cache'             => {
            "${cache_type}" => {
              'max-cache-size' => $max_cache_size,
              'eviction-time'  => $cache_eviction_time,
              'cache-failures' => $cache_failures,
      }}}},
    },
  } ->
  # lint:endignore

  # Prepare the authorization system for Wildfly role <-> LDAP group mappings
  # These are the Wildfly default authentication roles
  wildfly::util::resource { [
    '/core-service=management/access=authorization/role-mapping=Administrator',
    '/core-service=management/access=authorization/role-mapping=Auditor',
    '/core-service=management/access=authorization/role-mapping=Deployer',
    '/core-service=management/access=authorization/role-mapping=Maintainer',
    '/core-service=management/access=authorization/role-mapping=Monitor',
    '/core-service=management/access=authorization/role-mapping=Operator',
    '/core-service=management/access=authorization/role-mapping=SuperUser',
  ]:
    content => {},
  } ->

  # Configure Wildfly to use RBAC authorization
  wildfly::util::resource { '/core-service=management/access=authorization':
    content => {
      'provider' => 'rbac',
    }
  }

  if str2bool($apply_to_management_interface) {
    # Apply our newly created realm to the management interfaces
    wildfly::util::resource { '/core-service=management/management-interface=http-interface':
      content => {
        'security-realm' => $realm_name,
        'socket-binding' => 'management-http',
        'sasl-protocol'  => 'remote',
      },
    }

    Wildfly::Util::Resource['/core-service=management/access=authorization'] ->
      Wildfly::Util::Resource['/core-service=management/management-interface=http-interface']
  }

}