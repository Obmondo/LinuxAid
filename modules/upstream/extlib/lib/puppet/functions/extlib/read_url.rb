# frozen_string_literal: true

# Fetch a string from a URL (should only be used with 'small' remote files).
#
# This function should only be used with trusted/internal sources.
# This is especially important if using it in conjunction with `inline_template`
# or `inline_epp`.
# The current implementation is also very basic.  No thought has gone into timeouts,
# support for redirects, CA paths etc.
Puppet::Functions.create_function(:'extlib::read_url') do
  # @param url The URL to read from
  # @return Returns the contents of the url as a string
  # @example Calling the function
  #   extlib::read_url('https://example.com/sometemplate.epp')
  dispatch :read_url do
    param 'Stdlib::HTTPUrl', :url
    return_type 'String'
  end

  def read_url(url)
    require 'open-uri'
    uri = URI.parse(url)
    uri.read
  end
end
