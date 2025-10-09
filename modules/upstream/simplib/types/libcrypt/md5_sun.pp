# Regular expression pulled from the crypt(5) man page
# lint:ignore:single_quote_string_with_variables
type Simplib::Libcrypt::MD5_Sun = Pattern['^\$md5(,rounds=[1-9][0-9]+)?\$[./0-9A-Za-z]{8}\${1,2}[./0-9A-Za-z]{22}$']
# lint:endignore
