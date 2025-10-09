# Class: foo
#
# This class demonstrates the usage of the 'foo' class in Puppet.
# It takes a parameter 'bar', displays its value, and performs a redaction.
#
# Parameters:
#
# [*bar*]
#   The value of the 'bar' parameter.
#   Data Type: String
#
# Usage:
#
# class { 'foo':
#   bar => 'buzzbuzz',
# }
#
# The above code will instantiate the 'foo' class with the 'bar' parameter set to 'buzzbuzz'.
#
class foo (String $bar) { # lint:ignore:autoloader_layout 
  notice("The value of bar is ${bar}")

  redact($bar)
}

class { 'foo':
  bar => 'buzzbuzz',
}

notice("The value of foo::bar is ${foo::bar}")
