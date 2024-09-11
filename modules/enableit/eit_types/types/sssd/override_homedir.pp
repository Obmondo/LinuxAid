type Eit_types::Sssd::Override_homedir = Variant[
  Stdlib::Absolutepath,
  Enum[
    '/home/%u',
    '/home/%f',
    '/home/%P',
    '/home/%o',
  ],
]
