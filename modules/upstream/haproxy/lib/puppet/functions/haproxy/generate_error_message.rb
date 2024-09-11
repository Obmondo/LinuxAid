# frozen_string_literal: true

# Function created to generate error message. Any string as error message can be passed and the function can
# be called in epp templates.

Puppet::Functions.create_function(:'haproxy::generate_error_message') do
  dispatch :generate_error_message do
    param 'String', :error_message
  end

  def generate_error_message(error_message)
    raise(error_message)
  end
end
