# @summary
#  Install the RedHat yum repository for opensearch.
#
# @api private
#
class opensearch::repository::redhat {
  assert_private()

  $baseurl = $opensearch::version =~ Undef ? {
    true  => pick($opensearch::repository_location, 'https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/yum'),
    false => pick($opensearch::repository_location, "https://artifacts.opensearch.org/releases/bundle/opensearch/${opensearch::version[0]}.x/yum"),
  }

  yumrepo { 'opensearch':
    ensure        => $opensearch::repository_ensure,
    baseurl       => $baseurl,
    repo_gpgcheck => '1',
    gpgcheck      => '1',
    gpgkey        => $opensearch::repository_gpg_key,
  }
}
