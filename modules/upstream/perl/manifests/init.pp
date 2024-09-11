# Install perl modules from cpan

class perl {

  package { "perl" : ensure => present }
#  case $osfamily {
#    "RedHat" : { $package_name = ["make", "perl-App-cpanminus", "gcc" ] } 
#    "Debian" : { $package_name = ["make", "cpanminus", "gcc" ] }
#  }
  
#  package { $package_name : ensure => present, require => Package["perl"] }

#  define module (
#    $name, 
#    $ensure = "present" 
#    ) {
#    cpan { $name : ensure => $ensure }
#	} 

  define module (
    $ensure = "present"
  ) {
    $perl_module = prefix([$name], "perl-")
    package { $perl_module: ensure => $ensure }
  }
}
