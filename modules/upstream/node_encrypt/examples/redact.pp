class foo ($bar) {
  notice("The value of bar is ${bar}")
  redact('bar')
}

class { 'foo':
  bar => 'buzzbuzz',
}

notice("The value of foo::bar is ${foo::bar}")
