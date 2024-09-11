Puppet::Functions.create_function(:has_role) do
  dispatch :has_role do
    repeated_param 'String', :args
  end

  def has_role(*roles)
    if roles.count.zero?
      raise ArgumentError, 'Missing argument'
    end

    # If we subtract the array of classes from the `roles` variable, we can look
    # at the length of the result and compare it to `roles`; if shorter than
    # roles we match at least one.
    (roles - call_function('lookup', ['classes'])).size < roles.size
  end
end
