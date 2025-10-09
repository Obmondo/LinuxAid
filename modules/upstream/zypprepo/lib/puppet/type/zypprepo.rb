# frozen_string_literal: true

# Description of zypper repositories
require 'uri'

Puppet::Type.newtype(:zypprepo) do
  @doc = "The client-side description of a zypper repository. Repository
    configurations are found by parsing `/etc/zypp/zypp.conf` and
    the files indicated by the `reposdir` option in that file
    (see `zypper(8)` for details).

    Most parameters are identical to the ones documented
    in the `zypper(8)` man page.

    Continuation lines that zypper supports (for the `baseurl`, for example)
    are not supported. This type does not attempt to read or verify the
    exinstence of files listed in the `include` attribute."

  ensurable
  # Doc string for properties that can be made 'absent'
  ZYPPREPO_ABSENT_DOC = 'Set this to `absent` to remove it from the file completely.'
  ZYPP_BOOLEAN = %r{^(true|false|0|1|no|yes)$}.freeze
  ZYPP_BOOLEAN_DOC = 'Valid values are: false/0/no or true/1/yes.'

  munge_zypp_bool = proc do |val|
    val.to_s == 'absent' ? :absent : val.to_s.capitalize
  end

  ZYPPREPO_VALID_SCHEMES = %w[file http https ftp cd].freeze

  newparam(:name, namevar: true) do
    desc "The name of the repository.  This corresponds to the
      `repositoryid` parameter in `zypper(8)`."
  end

  newproperty(:descr) do
    desc "A human-readable description of the repository.
      This corresponds to the name parameter in `zypper(8)`.
      #{ZYPPREPO_ABSENT_DOC}"
    newvalues(%r{.*}, :absent)
  end

  newproperty(:mirrorlist) do
    desc "The URL that holds the list of mirrors for this repository.
      #{ZYPPREPO_ABSENT_DOC}"
    newvalues(%r{.*}, :absent)
    validate do |value|
      next if value.to_s == 'absent'

      parsed = URI.parse(value)

      raise _('Must be a valid URL') unless ZYPPREPO_VALID_SCHEMES.include?(parsed.scheme)
    end
  end

  newproperty(:baseurl) do
    desc "The URL for this repository. #{ZYPPREPO_ABSENT_DOC}"
    newvalues(%r{.*}, :absent)
    validate do |value|
      next if value.to_s == 'absent'

      value.split(%r{\s+}).each do |uri|
        parsed = URI.parse(uri)

        raise _('Must be a valid URL') unless ZYPPREPO_VALID_SCHEMES.include?(parsed.scheme)
      end
    end
  end

  newproperty(:path) do
    desc "The path relative to the baseurl. #{ZYPPREPO_ABSENT_DOC}"
    newvalues(%r{.*}, :absent)
  end

  newproperty(:enabled) do
    desc "Whether this repository is enabled.
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:gpgcheck) do
    desc "Whether to check the GPG signature from this repository
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:repo_gpgcheck) do
    desc "Whether to check the GPG signature on the repository metadata
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:pkg_gpgcheck) do
    desc "Whether to check the GPG signature on packages installed
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:gpgkey) do
    desc "The URL for the GPG key with which packages from this
      repository are signed. #{ZYPPREPO_ABSENT_DOC}"

    newvalues(%r{.*}, :absent)
    validate do |value|
      next if value.to_s == 'absent'

      value.split(%r{\s+}).each do |uri|
        parsed = URI.parse(uri)

        raise _('Must be a valid URL') unless ZYPPREPO_VALID_SCHEMES.include?(parsed.scheme)
      end
    end
  end

  newproperty(:priority) do
    desc "Priority of this repository. Can be any integer value
      (including negative). Requires that the `priorities` plugin
      is installed and enabled.
      #{ZYPPREPO_ABSENT_DOC}"

    newvalues(%r{^-?\d+$}, :absent)
  end

  newproperty(:autorefresh) do
    desc "Enable autorefresh of the repository.
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:keeppackages) do
    desc "Enable RPM files caching
    #{ZYPP_BOOLEAN_DOC}
    #{ZYPPREPO_ABSENT_DOC}"
    newvalues(ZYPP_BOOLEAN, :absent)
    munge(&munge_zypp_bool)
  end

  newproperty(:type) do
    desc "The type of software repository. Values can match
       `yast2` or `rpm-md` or `plaindir` or `yum` or `NONE`. #{ZYPPREPO_ABSENT_DOC}"
    newvalues(%r{yast2|rpm-md|plaindir|yum|NONE}, :absent)
  end
end
