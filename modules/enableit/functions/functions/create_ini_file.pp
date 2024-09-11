function functions::create_ini_file (
  Stdlib::Absolutepath $name,
  Hash                 $settings,
  Optional[Hash]       $defaults = {},
) {

  # Make sure arrays are joined with a space;
  $_settings = Hash($settings.map |$k, $v| {
    [$k, case $v {
      Sensitive: {
        $v.unwrap
      }
      Array: {
        # Make sure no values in the array has a space in it
        $v.each |$x| {
          if $x =~ / / {
            fail('Values for ini files can not have spaces')
          }
        }

        join($v, ' ')
      }
      default: { $v }
    }]
  })

  # Make sure we default to the file being present
  $_defaults = merge({
    ensure => 'file',
  }, $defaults)

  file { $name:
    content => epp('functions/ini_file.epp', {settings => $_settings}),
    *       => $_defaults,
  }

}
