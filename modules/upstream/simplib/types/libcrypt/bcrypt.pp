# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::Bcrypt = Pattern['^\$2[abxy]\$[0-9]{2}\$[./A-Za-z0-9]{53}$']
