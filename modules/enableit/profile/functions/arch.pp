# @summary Determines the appropriate architecture string for NetBird based on OS facts
#
# This function analyzes the system architecture and operating system to return
# the correct architecture identifier for NetBird installation packages.
#
# @return [String] The architecture string to use for NetBird
#   - Returns 'armv6' for TurrisOS systems with ARM architecture
#   - Returns 'arm64' for other systems with ARM architecture
#   - Returns 'amd64' for non-ARM architectures as default value
#
# @example Basic usage
#   $netbird_arch = profile::netbird_arch()
#   # Returns 'arm64' on most ARM systems, 'armv6' on TurrisOS
#
# @example Using in a package resource
#   archive { "/tmp/netbird_${version}.tar.gz":
#       ensure       => ensure_present($enable),
#       source       => "https://github.com/netbirdio/netbird/releases/download/v${version}/netbird_${version}_${_kernel}_${_arch}.tar.gz",
#       extract      => true,
#       extract_path => '/tmp',
#       creates      => '/tmp/netbird',
#       cleanup      => true,
#       noop         => $noop_value,
#     }
#
# @author Sidharth Jawale
# @since 1.0.0
function profile::arch {
  $os_arch = $facts['os']['architecture']

  case $os_arch {
    /^arm/:{
      $os_arch.chop # return armv7
    }
    default: {
      'amd64'
    }
  }
}
