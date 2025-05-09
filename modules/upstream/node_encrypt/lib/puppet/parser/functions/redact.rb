# frozen_string_literal: true

Puppet::Parser::Functions.newfunction(:redact, doc: <<~DOC
  This function will modify the catalog during compilation to remove the named
  parameter from the class from which it was called. For example, if you wrote a
  class named `foo` and called `redact('bar')` from within that class, then the
  catalog would not record the value of `bar` that `foo` was called with.

  ~~~ puppet
  class foo($bar) {
    # this call will display the proper output, but because it's not a resource
    # the string won't exist in the catalog.
    notice("Class['foo'] was called with param ${bar}")

    # but the catalog won't record what the passed in param was.
    redact('bar')
  }

  class { 'foo':
    bar => 'this will not appear in the catalog',
  }
  ~~~

  **Warning**: If you use that parameter to declare other classes or resources,
  then you must take further action to remove the parameter from those declarations!

  This takes an optional second parameter of the value to replace the original
  parameter declaration with. This parameter is required if the class declares
  a type that is not `String` for the parameter you're redacting.
DOC
) do |args|
  raise Puppet::ParseError, 'The redact function requires 1 or 2 arguments' unless [1, 2].include? args.size

  param   = args[0]
  message = args[1] || '<<redacted>>'

  # find the class in the catalog matching the name of the class this was called in
  klass = catalog.resources.find do |res|
    (source.type == :hostclass && res.type == 'Class' && res.name.downcase == source.name) ||
      (source.type != :hostclass && res.type.downcase == source.name && res.title.casecmp(resource.name).zero?)
  end

  # and rewrite its parameter
  if klass.type == 'Class'
    klass.parameters[param.to_sym].value = message
  else
    # For defined types, the parameter object might be shared with other instances of the type, (if it was declared with a per resource default attribute).
    # We must only redact the specific instance as the others won't have added their resources yet and still need the parameter unredacted.
    parameter = klass.parameters[param.to_sym].dup
    parameter.value = message
    klass.parameters[param.to_sym] = parameter
  end
end
