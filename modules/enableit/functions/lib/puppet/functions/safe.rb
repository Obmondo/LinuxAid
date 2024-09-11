# Lookup a variable and fail if undefined and no alternative is given.
#
# For example:
#
#     $foo = safe('site::data::foo')
#     # Equivalent to $foo = $site::data::foo
#
#     $foo = safe('site::data::foo', 'asd')
#     # Equivalent to $foo = $site::data::foo; if the variable is undef (nil), the value of
#     # $foo will be 'asd'
#
# Especially useful in templates; call it like so:
#
#     scope.function_safe(['::site::data::foo'])
#     scope.function_safe(['::site::data::foo', 'default'])
#
# e.g.:
#
#     VAR1=<%= scope.function_safe(['::site::data::foo']) %>
#     VAR2=<%= scope.function_safe(['::site::data::omg', 'default']) %>
Puppet::Functions.create_function(:safe) do

  def safe(*args)
    unless args.length == 1 or args.length == 2
      raise Puppet::ParseError, ("safe(): wrong number of arguments (#{args.length}; must be 1)")
    end

    out = self.lookupvar("#{args[0]}")

    if out.nil?
      if args[1].nil?
        raise Puppet::ParseError, ("safe(): could not lookup var `#{args[0]}` and no alternative was given")
      end

      out = args[1]
    end

    out
  end
end
