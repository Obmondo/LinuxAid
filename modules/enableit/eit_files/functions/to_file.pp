# Return an Obmondo file resource hash
function eit_files::to_file (
  Eit_Files::Source $source,
) {

  $_obmondo_file_regexp = Regexp('^obmondo:///')
  $_file_name = $source.regsubst($_obmondo_file_regexp, '')
  $_resource_location = "customers::${facts['obmondo']['customer_id']}::files"
  $_is_dir = $_file_name =~ /\/$/

  # Look up and merge with a default resource adding defaults
  $_resources = {
    $_file_name => {
      __name  => $_file_name,
      recurse => $_is_dir,
      ensure  => if $_is_dir { 'directory' } else { 'file' },
    },
  } + lookup($_resource_location, Hash, { 'strategy' => 'deep'}, {})

  $_resource = $_resources.dig($_file_name)

  unless $_resource {
    fail("Broken Obmondo file resource; can't find '${_file_name}'

All resources: ${_resources}
")
  }

  Hash([
    [
      'resource',
      $_resource - {
        __name => undef,      # ensure that our custom `__name` key is removed
      } + {
        source => "puppet:///modules/customers/${_file_name}",
      },
    ],
    [
      'name',
      $_resource['__name'],
    ]
  ])
}
