# Valid entries for the password field of the 'shadow' file
#
# These items are recognized by recent versions of crypt but may not be exhaustive
#
# Regular expressions pulled from the crypt(5) man page
#
# They are ordered of most to least commonly used for optimization.
#
# Just because they are allowed, does not mean that you should use them....
type Simplib::ShadowPass = Variant[
  Enum['*','!','!!'],
  # Disabled Entries
  Pattern['^!.*'],
  Simplib::Libcrypt::SHA2_512,
  Simplib::Libcrypt::SHA2_256,
  Simplib::Libcrypt::SHA1,
  Simplib::Libcrypt::MD5_Sun,
  Simplib::Libcrypt::MD5_FreeBSD,
  Simplib::Libcrypt::NTHASH,
  Simplib::Libcrypt::Bcrypt,
  Simplib::Libcrypt::Scrypt,
  Simplib::Libcrypt::Yescrypt
]
