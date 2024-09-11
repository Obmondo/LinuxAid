# Validate that the passed value is correct for the passed `sysctl` key.
#
# * If a key is not known, assumes the value is valid.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_sysctl_value') do

  # @param key sysctl setting whose value is to be validated
  # @param value Value to be validated
  # @return [Nil]
  # @raise [RuntimeError] upon validation failure
  # @example Passing validation
  #   validate_sysctl_value('kernel.core_pattern','/var/core/%u_%g_%p_%t_%h_%e.core')

  dispatch :validate_sysctl_value do
    required_param 'String',:key
    required_param 'NotUndef',:value
  end

  def validate_sysctl_value(key, value)

    key_method_name = key.to_s.gsub('.','__')

    self.send(key_method_name, key, value) if self.respond_to?(key_method_name)
  end

  # Below are the recognized validation methods

  def kernel__core_pattern(key, value)
    unless value.is_a?(String)
      validate_sysctl_err("Values for #{key} must be Strings")
    end

    if value.length > 128
      validate_sysctl_err("Values for #{key} must be less than 129 characters")
    end

    if value =~ /\|\s*(\S*)/
      require 'puppet/util'
      unless  Puppet::Util.absolute_path?($1, :posix)
        validate_sysctl_err("Piped commands for #{key} must have an absolute path")
      end
    end
  end

  def fs__inotify__max_user_watches(key, value)
    if !value.respond_to?('to_i') || value.to_i == 0
      validate_sysctl_err("#{key} cannot be #{value}")
    end

    system_ram_mb = closure_scope['facts']['memorysize_mb']

    if system_ram_mb
      system_ram_mb = system_ram_mb.to_i

      size_multiplier = 512
      size_multiplier = 1024 if (closure_scope['facts']['architecture'] == 'x86_64')

      inode_ram_mb = (value.to_i * size_multiplier)/1024/1024

      if inode_ram_mb >= system_ram_mb
        validate_sysctl_err("#{key} set to #{value} would exceed system RAM")
      end
    end
  end

  def validate_sysctl_err(msg)
    fail("simplib::validate_sysctl_value(): #{msg}")
  end
end
