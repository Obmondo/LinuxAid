# Class: purge
#
# Accepts a hash of purge resources to create, see README.
#
class purge (
  Hash $resources = {},
)
{
  $resources.each | String $resource_name, Hash $attrs | {
    purge { $resource_name:
      * => $attrs,
    }
  }
}
