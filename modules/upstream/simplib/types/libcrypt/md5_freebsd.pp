# Regular expression pulled from the crypt(5) man page
#
# The salt is a negated character class, which matches a newline even when the
# pattern is anchored to the whole string, so newlines are excluded explicitly
type Simplib::Libcrypt::MD5_FreeBSD = Pattern['\A\$1\$[^$\n]{1,8}\$[./0-9A-Za-z]{22}\z']
