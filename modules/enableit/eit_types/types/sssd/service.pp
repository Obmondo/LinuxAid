# sssd services available on CentOS 7.5

# systemctl list-unit-files |grep -Eo '^sssd-[^.]+'

type Eit_types::Sssd::Service = Enum[
  'autofs',
  'ifp',
  'nss',
  'pac',
  'pam',
  'pam-priv',
  'secrets',
  'ssh',
  'sudo',
]
