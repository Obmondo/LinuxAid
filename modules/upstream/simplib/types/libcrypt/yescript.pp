# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::Yescrypt = Pattern['^\$y\$[./A-Za-z0-9]+\$[./A-Za-z0-9]{,86}\$[./A-Za-z0-9]{43}$']
