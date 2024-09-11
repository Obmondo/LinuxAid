# Kolab enableit role
class role::customers::enableit::kolab (
  String $upload_max_filesize = '20M',
  String $post_max_size       = '21M',
) inherits role::customers {

  include profile::enableit::kolab
}
