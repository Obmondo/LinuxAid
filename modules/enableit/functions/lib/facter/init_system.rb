# Fact that returns the primary init system for a particular system using
# either a curated list of known answers, or falling back to automatic
# detection.


def initsystem_lookup

  # Whilst we include logic for automatically selecting the initsystem based
  # on what is present on the system, it doesn't always work 100% since there
  # are some distributions with multiple init systems present, and it's not
  # always the case of the most modern init system being the right one to use.
  #
  # Hence, here we do a lookup against our curated list for a specific
  # configured match:
  initsystem = initsystem_curated

  if initsystem.empty?
    # We don't have a specific match for this system, so let's check for
    # various known platforms.

    # TODO: this could be a lot more sophisticated, patches welcome.

    if File.exists?('/bin/systemctl')
      return 'systemd'
    elsif File.exists?('/sbin/upstart-local-bridge')
      return 'upstart'
    else
      # sysvinit is the safest default to fall back to, even many distributions
      # with other init systems maintain some compatibility.
      return 'sysvinit'
    end
  else
    return initsystem
  end

end


def initsystem_curated
  case Facter.value(:osfamily)

  when 'RedHat'
    case Facter.value(:operatingsystem)

    when 'Amazon'
      # Whilst Amazon Linux is based off EL, it has quite different versioning
      # and has yet to make it to systemd.
      case Facter.value(:operatingsystemmajrelease)
      when '2014'
        'sysvinit'
      when '2015'
        'sysvinit'
      else
        '' # No match, fall back to auto-resolving
      end

    else
      # Default RedHat generally means RHEL, CentOS or some other clone
      case Facter.value(:operatingsystemmajrelease)

      when '5'
        'sysvinit'
      when '6'
        'sysvinit' # RHEL 6 also has upstart, but the service tools don't handle it right. Stick to sysvinit here.
      when '7'
        'systemd'
      else
        '' # No match, fall back to auto-resolving
      end
    end

  when 'Debian'
    case Facter.value(:operatingsystem)
    when 'Ubuntu'
      case Facter.value(:operatingsystemmajrelease)
      when '12.04'
        'upstart'
      when '14.04'
        'upstart'
      when '14.10'
        'upstart'
      when '15.04'
        'systemd'
      else
        '' # No match, fall back to auto-resolving
      end

    when 'Debian'
      case Facter.value(:operatingsystemmajrelease)
      when '6'
        'sysvinit'
      when '7'
        'sysvinit'
      when '8'
        'systemd'
      else
        '' # No match, fall back to auto-resolving
      end

    else
      '' # No match, fall back to auto-resolving
    end

  when 'FreeBSD'
    case Facter.value(:operatingsystemmajrelease)
    when '9'
      'bsdinit'
    when '10'
      'bsdinit'
    else
      'bsdinit' # don't see them being likely to pickup systemd anytime soon
    end

  when 'Darwin'
    'launchd'

  else
    '' # No match, fall back to auto-resolving
  end
end


begin
  Facter.add('init_system') { setcode { initsystem_lookup } }
rescue => e
  puts "An unexpected issue occured when trying to resolve the init system fact."
  raise e
end
