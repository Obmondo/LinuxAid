# frozen_string_literal: true

# @summary
#   This converts a puppet hash to an INI string.
#
#   Based on https://github.com/mmckinst/puppet-hash2stuff/blob/master/lib/puppet/parser/functions/hash2ini.rb
#
# @example How to output ini to a file
#   file { '/tmp/config.ini':
#     ensure  => file,
#     content => extlib::to_ini($myhash),
#   }
Puppet::Functions.create_function(:'extlib::to_ini') do
  # @param data Data structure which needs to be converted into ini
  # @param settings Override default ini generation settings
  # @return [String] Converted data as ini string
  dispatch :to_ini do
    required_param 'Hash', :data
    optional_param 'Hash', :settings
    return_type 'String'
  end

  def to_ini(data, settings = {})
    default_settings = {
      'header'            => '# THIS FILE IS CONTROLLED BY PUPPET',
      'section_prefix'    => '[',
      'section_suffix'    => ']',
      'key_val_separator' => '=',
      'quote_char'        => '"',
      'quote_booleans'    => true,
      'quote_numerics'    => true,
    }

    settings = default_settings.merge(settings)

    ini = []
    ini << settings['header'] << nil
    data.each_key do |section|
      ini << "#{settings['section_prefix']}#{section}#{settings['section_suffix']}"
      data[section].each do |k, v|
        v_is_a_boolean = (v.is_a?(TrueClass) or v.is_a?(FalseClass))

        ini << if (v_is_a_boolean && !(settings['quote_booleans'])) || (v.is_a?(Numeric) && !(settings['quote_numerics']))
                 "#{k}#{settings['key_val_separator']}#{v}"
               else
                 "#{k}#{settings['key_val_separator']}#{settings['quote_char']}#{v}#{settings['quote_char']}"
               end
      end
      ini << nil
    end
    ini.join("\n")
  end
end
