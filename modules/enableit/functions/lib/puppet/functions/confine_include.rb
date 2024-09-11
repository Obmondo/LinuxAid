# Includes a module if the second argument is true.
# Example:
#  confine_include('::common::backup::mysql', $backup and !$facts['mysqld_datadir_on_root'])

Puppet::Functions.create_function(:confine_include, options = {
  :arity => 2,
}) do

  def confine_include(*arguments)
    classname, boolean = arguments
    boolean and call_function('include', [classname])
  end
end
