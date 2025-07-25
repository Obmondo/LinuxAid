# Prints the passed variable's Ruby type and value for debugging purposes
#
# This uses a ``Notify`` resource to print the information during the client
# run.
#
# @param var_name
#   The actual name of the variable, fully scoped, as a ``String``
#
# @param output_type
#   The format that you wish to use to display the output during the
#   run. 'json' and 'yaml' result in multi-line message content.
#   'oneline_json' results in single-line message content.
#
# @return [None]
#
# @example Debugging variable content
#
# class my_test(
#   String $var1,
#   Hash   $var2
# )
# {
#   simplib::inspect('var1')
#   simplib::inspect('var2')
#   ...
# }
#
function simplib::inspect (
  String $var_name,
  Enum['json','yaml', 'oneline_json'] $output_type = 'json'
) {

  if $output_type == 'oneline_json' {
    $_output_type = 'json'
  }
  else {
    $_output_type = $output_type
  }

  $var_value = inline_template("<%= scope[@var_name].to_${_output_type} %>")
  $var_class = inline_template('<%= scope[@var_name].class %>')

  if $output_type == 'oneline_json' {
    $_separator = ' '
  }
  else {
    $_separator = "\n"
  }


  notify { "DEBUG_INSPECT_${var_name}":
    message => "Type => ${var_class}${_separator}Content =>${_separator}${var_value}"
  }
}
