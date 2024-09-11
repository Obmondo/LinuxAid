# frozen_string_literal: true

Puppet::Type.newtype(:dnf_module_stream) do
  @doc = <<-TYPE_DOC
    @summary Manage DNF module streams
    @example Enable MariaDB default stream
      dnf_module_stream { 'mariadb':
        stream => default,
      }
    @example Enable MariaDB 10.5 stream
      dnf_module_stream { 'mariadb':
        stream => '10.5',
      }
    @example Disable MariaDB streams
      dnf_module_stream { 'mariadb':
        stream => absent,
      }
    @param module
      Module to be managed - Defaults to title
    @param stream
      Module stream to be enabled

    This type allows Puppet to enable/disable streams via DNF modules
  TYPE_DOC

  newparam(:title, namevar: true) do
    desc 'Resource title'
    newvalues(%r{.+})
  end

  newparam(:module) do
    desc 'DNF module to be managed'
    newvalues(%r{.+})
  end

  newproperty(:stream) do
    desc <<-EOS
      Module stream that should be enabled
        String - Specify stream
        present - Keep current enabled stream if any, otherwise enable default one
        default - Enable default stream
        absent - No stream (resets module)
    EOS
    newvalues(:present, :default, :absent, %r{.+})
  end
end
