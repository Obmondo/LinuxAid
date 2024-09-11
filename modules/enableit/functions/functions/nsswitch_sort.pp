# Nsswitch sort the array based on their element
# [ 'files', 'nis', 'db' ] => ['files', 'db', 'nis']
function functions::nsswitch_sort (
  Array $array,
) {

  # NOTE: This is all the option one can set and
  # setting up the order as per experience
  # https://www.man7.org/linux/man-pages/man5/nsswitch.conf.5.html
  $order = {
    0 => 'files',
    1 => 'compat',
    2 => 'db',
    3 => 'systemd',
    4 => 'sss',
    5 => 'nis',
  }

  $arranged= [
    # When 'files' and 'compat' are present in the array,
    # select files and leave out compat
    if 'files' in $array and 'compat' in $array {
      'files'
    } elsif 'files' in $array {
      if $order[0] in $array { 'files' }
    } elsif 'compat' in $array {
      if $order[1] in $array { 'compat' }
    },
    if $order[2] in $array { 'db' },
    if $order[3] in $array { 'systemd' },
    if $order[4] in $array { 'sss' },
    if $order[5] in $array { 'nis' },
  ].flatten.delete_undef_values.unique
}
