# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::SHA2_512 = Pattern['^\$6\$(rounds=[1-9][0-9]+\$)?[./0-9A-Za-z]{1,16}\$[./0-9A-Za-z]{86}$']
