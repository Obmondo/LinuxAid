################################################################################
# Time-stamp: <Thu 2022-06-30 14:27 svarrette>
#
# File::      <tt>build.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::build
#
# This definition takes care of building Slurm sources into RPMs using 'rpmbuild'.
# It expect to get as resource name the SLURM version to build
# This assumes the sources have been downloaded using slurm::download
#
#
# @param ensure  [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param srcdir  [String] Default: '/usr/local/src'
#          Where the [downloaded] Slurm sources are located
# @param dir     [String] Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <dir>/RPMS/${::architecture}
# @param with    [Array] Default: [ 'lua', ... ] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --with build options to pass to rpmbuild
# @param without [Array] Default: [] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --without build options to pass to rpmbuild
#
# @example Building version 19.05.3-2 of SLURM
#
#     slurm::build { '19.05.3-2':
#        ensure => 'present',
#        srcdir => '/usr/local/src',
#        dir    => '/root/rpmbuild',
#        with   => [ 'hdf5', 'hwloc', lua', 'mysql', 'numa', 'pmix' ]
#     }
#
# This will typically run the following rpmbuild command:
#
#     rpmbuild -ta --with hdf5 --with hwloc --with lua --with mysql --with numa --with pmix \
#              --define "_topdir /root/rpmbuild" --define "_with_pmix --with-pmix=/usr" \
#              /usr/local/src/slurm-19.05.3-2.tar.bz2
#
# and thus produce the following RPMs under /root/rpmbuild/RPMS/x86_64/:
#
#      slurm-19.05.3-2.el7.x86_64.rpm
#      slurm-contribs-19.05.3-2.el7.x86_64.rpm
#      slurm-devel-19.05.3-2.el7.x86_64.rpm
#      slurm-example-configs-19.05.3-2.el7.x86_64.rpm
#      slurm-libpmi-19.05.3-2.el7.x86_64.rpm
#      slurm-openlava-19.05.3-2.el7.x86_64.rpm
#      slurm-pam_slurm-19.05.3-2.el7.x86_64.rpm
#      slurm-perlapi-19.05.3-2.el7.x86_64.rpm
#      slurm-slurmctld-19.05.3-2.el7.x86_64.rpm
#      slurm-slurmd-19.05.3-2.el7.x86_64.rpm
#      slurm-slurmdbd-19.05.3-2.el7.x86_64.rpm
#      slurm-torque-19.05.3-2.el7.x86_64.rpm
#
define slurm::build(
  String  $ensure  = $slurm::params::ensure,
  String  $srcdir  = $slurm::params::srcdir,
  String  $dir     = $slurm::params::builddir,
  Array   $with    = $slurm::params::build_with,
  Array   $without = $slurm::params::build_without,
)
{
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ '\d+[\.-]?' ])

  # $name is provided at define invocation
  $version = $name

  # Path to the SLURM sources
  $src = "${srcdir}/slurm-${version}.tar.bz2"

  # Prepare the [RPM] build option
  $with_options = empty($with) ? {
    true    =>  '',
    default => join(prefix($with, '--with '), ' ')
  }
  # NOT YET IMPLEMENTED:
  # if ('pmix' in $with)
  #    find a way to set --with pmix=${slurm[::params]::pmix_install_path}
  #    (by default, installed under /usr so all good...)

  $without_options = empty($without) ? {
    true    =>  '',
    default => join(prefix($without, '--without '), ' ')
  }

  # Label for the exec
  $buildname = $ensure ? {
    'absent'  => "uninstall-slurm-${version}",
    default   => "build-slurm-${version}",
  }

  # Management of PMIx
  if ($slurm::with_pmix or ('pmix' in $with)) {
    if !defined(Class['::slurm::pmix']) {
      include ::slurm::pmix
      Class['::slurm::pmix'] -> Exec[$buildname]
      # Slurm::Pmix::Install[$slurm::pmix::version] -> Exec[$buildname]
    }
    $define_pmix = "--define \"_with_pmix --with-pmix=${slurm::params::pmix_install_path}\""
  } else {
    $define_pmix = ''
  }

  case $::osfamily {
    'Redhat': {
      include ::epel
      include ::yum
      if !defined(Yum::Group[$slurm::params::groupinstall]) {
        yum::group { $slurm::params::groupinstall:
          ensure  => 'present',
          timeout => 600,
          require => Class['::epel'],
        }
      }
      Yum::Group[$slurm::params::groupinstall] -> Exec[$buildname]

      $rpmdir = "${dir}/RPMS/${::architecture}"
      $rpms   = prefix(suffix(concat($slurm::params::common_rpms_basename, $slurm::params::slurmdbd_rpms_basename),
                              "-${version}*.rpm"), "${rpmdir}/")
      # the below command should typically produce the following RPMs
      # slurm[-suffix]-<version>-1.el7.centos.x86_64.rpm
      case $ensure {
        'absent': {
          $cmd          = "rm -f ${rpmdir}/slurm*-${version}*.rpm"
          $check_onlyif = "test -n \"$(ls ${rpms[0]} 2>/dev/null)\""
          $check_unless = undef
        }
        default: {
          $cmd          = "rpmbuild -ta ${with_options} ${without_options} --define \"_topdir ${dir}\" ${define_pmix} ${src}"
          $check_onlyif = undef
          $check_unless = suffix(prefix($rpms, 'test -n "$(ls '), ' 2>/dev/null)"')
          #"test -n \"$(ls ${main_rpm} 2>/dev/null)\""
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # notice($cmd)
  exec { $buildname:
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $cmd,
    cwd     => '/root',
    user    => 'root',
    timeout => 600,
    onlyif  => $check_onlyif,
    unless  => $check_unless,
  }
}
