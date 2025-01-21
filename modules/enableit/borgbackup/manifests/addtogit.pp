# internal define to add a repo to git.
#
# Parameters:
#  $passphrase:
#    passphrase to set.
#    if set to 'random', a random passphrase is generated
#  $reponame:
#    the name of the repository
define borgbackup::addtogit (
  String $passphrase,
  String $reponame,
) {

  include ::borgbackup::git

  $gpg_home = $borgbackup::git::gpg_home
  $git_home = $borgbackup::git::git_home
  $configdir = $borgbackup::git::configdir

  $keys=join(
    [
      "--recipient 'borg ${facts['networking']['fqdn']}' --recipient ",
      $borgbackup::git::gpg_keys.keys().join(' --recipient '),
    ],''
  )

  # set exec defaults
  Exec {
    environment => [ "GNUPGHOME=${gpg_home}" ],
    path        => '/usr/bin:/usr/sbin:/bin',
    notify      => Exec['commit git repo'],
  }


  if $passphrase == 'random' {
    # just create the file if it does non exist, or we cannot decrypt it
    exec { "create passphrase file ${title}":
      command => "cat /dev/random |tr -dc _A-Z-a-z-0-9 | head -c30 | gpg --encrypt --always-trust ${keys} > ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg", #lint:ignore:140chars
      require => [Exec["create gpg private key for ${facts['networking']['fqdn']}"], File["${git_home}/${facts['networking']['fqdn']}"]],
      before  => Exec["initialize borg repo ${reponame}"],
      unless  => [
        # we cannot decrypt the file (so it's probably the same host, newly setup, or file does not exist
        "gpg --decrypt -v --output /dev/null ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg",
      ],
    }
  } else {
    # passphrase is explicitly set.
    $md5_passphrase = md5("${passphrase}\n")

    exec { "create passphrase file ${title}":
      command => "echo ${passphrase} | gpg --encrypt --always-trust ${keys} > ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg",
      require => [Exec["create gpg private key for ${facts['networking']['fqdn']}"], File["${git_home}/${facts['networking']['fqdn']}"]],
      before  => Exec["initialize borg repo ${reponame}"],
      unless  => [
        # check if file contains passphrase
        "gpg -q --decrypt ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg |md5sum| grep -e '^${md5_passphrase}'",
      ],
    }
  } # end if $passphrase == 'random'

  # we use the name of the key, which needs to be the email address
  # shown with 'gpg  --decrypt -vv --output /dev/null default_pass.gpg'
  # on the host to backup
  $md5_keys=md5(sprintf("%s\n",downcase($borgbackup::git::gpg_keys.keys()).sort().join("\n")))

  exec { "reencrypt passphrase file ${title}":
    command => "gpg --decrypt ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg | gpg --encrypt --always-trust ${keys} > ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg", #lint:ignore:140chars
    require => Exec["create passphrase file ${title}"],
    unless  => [
      # check if file is encrypted with correct keys
      "gpg --decrypt -v --output /dev/null ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg 2>&1 |sed -n 's/^ .*<\\(.*\\)>\"$/\\L\\1/p'|sort|md5sum|grep -e '^${md5_keys}'", #lint:ignore:140chars
    ],
  }

  exec { "create key file ${title}":
    command  => "${configdir}/repo_${reponame}.sh exportkey | gpg --encrypt --always-trust ${keys} > ${git_home}/${facts['networking']['fqdn']}/${reponame}_keyfile.gpg", #lint:ignore:140chars
    require  => [Exec["initialize borg repo ${reponame}", "create gpg private key for ${facts['networking']['fqdn']}"], File["${git_home}/${facts['networking']['fqdn']}"]],
    provider => 'shell',
    unless   => [
      # check if file contains key
      "A=`${configdir}/repo_${reponame}.sh exportkey|md5sum`; gpg --decrypt --output - ${git_home}/${facts['networking']['fqdn']}/${reponame}_keyfile.gpg |md5sum|grep \$A", #lint:ignore:140chars
    ],
  }

  exec { "reencrypt key file ${title}":
    command => "gpg --decrypt ${git_home}/${facts['networking']['fqdn']}/${reponame}_keyfile.gpg | gpg --encrypt --always-trust ${keys} > ${git_home}/${facts['networking']['fqdn']}/${reponame}_keyfile.gpg", #lint:ignore:140chars
    require => [Exec["initialize borg repo ${reponame}", "create gpg private key for ${facts['networking']['fqdn']}","create key file ${title}"], File["${git_home}/${facts['networking']['fqdn']}"]], #lint:ignore:140chars
    unless  => [
      # check if file is encrypted with correct keys
      "gpg --decrypt -v --output /dev/null ${git_home}/${facts['networking']['fqdn']}/${reponame}_pass.gpg 2>&1 |sed -n 's/^ .*<\\(.*\\)>\"$/\\L\\1/p'|sort|md5sum|grep -e '^${md5_keys}'", #lint:ignore:140chars
    ],
  }
}

