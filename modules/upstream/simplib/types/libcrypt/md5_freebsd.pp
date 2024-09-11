# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::MD5_FreeBSD = Pattern['^\$1\$[^$]{1,8}\$[./0-9A-Za-z]{22}$']
