define wildfly::web::ssl(
  $connector,
  $password,
  $protocol,
  $cipher_suite,
  $key_alias,
  $certificate_key_file,
  $ca_certificate_file = undef) {

  $params = {
    'name' => $title,
    'password' => $password,
    'protocol' => $protocol,
    'cipher-suite' => $cipher_suite,
    'key-alias' => $key_alias,
    'certificate-key-file' => $certificate_key_file,
    'ca-certificate-file' => $ca_certificate_file,
  }

  wildfly::resource { "/subsystem=web/connector=${connector}/ssl=configuration":
    content => $params
  }

}
