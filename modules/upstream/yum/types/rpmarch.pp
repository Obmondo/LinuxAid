# @summary Valid rpm architectures.
# Output of `rpm -q --queryformat '%{arch}\n' package`
# @see https://github.com/rpm-software-management/rpm/blob/master/rpmrc.in
type Yum::RpmArch = Enum[
  'noarch',
  'x86_64',
  'i386',
  'aarch64',
  'arm',
  'ppc64',
  'ppc64le',
  'sparc64',
  'ia64',
  'alpha',
  'ip',
  'm68k',
  'mips',
  'mipsel',
  'mk68k',
  'mint',
  'ppc',
  'rs6000',
  's390',
  's390x',
  'sh',
  'sparc',
  'xtensa',
]
