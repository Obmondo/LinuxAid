# frozen_string_literal: true

# Get Samba version

# FIXME: we do this because apparently confine for aggregate facts are broken...
if Facter::Util::Resolution.which('smbd')
  Facter.add(:samba, type: :aggregate) do
    confine kernel: :linux
    confine { Facter::Util::Resolution.which('smbd') }

    version = Facter::Core::Execution
              .execute('smbd --version 2>&1')
              .match(/^Version (\d+\.\d+\.\d+).*$/)[1]
    version_parts = version.split('.') if version

    chunk(:version) do
      { version: version }
    end

    chunk(:version_major) do
      { version_major: version_parts.dig(0) }
    end

    chunk(:version_minor) do
      { version_minor: version_parts.dig(1) }
    end

    chunk(:version_patch) do
      { version_patch: version_parts.dig(2) }
    end
  end
end
