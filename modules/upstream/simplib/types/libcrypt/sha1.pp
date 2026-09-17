# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::SHA1 = Pattern['\A\$sha1\$[1-9][0-9]+\$[./0-9A-Za-z]{1,64}\$[./0-9A-Za-z]{8,64}[./0-9A-Za-z]{32}\z']
