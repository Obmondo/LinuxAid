# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::Scrypt = Pattern['^\$7\$[./A-Za-z0-9]{11,97}\$[./A-Za-z0-9]{43}$']
