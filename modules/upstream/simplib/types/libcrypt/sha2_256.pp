# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::SHA2_256 = Pattern['\A\$5\$(rounds=[1-9][0-9]+\$)?[./0-9A-Za-z]{1,16}\$[./0-9A-Za-z]{43}\z']
