Puppet::Type.type(:reboot_notify).provide(:notify) do
  desc 'Management of the reboot notification metadata file.'

  # Simple accessor for common data
  def self.target
    File.join(Puppet[:vardir], 'reboot_notifications.json')
  end

  # Instance syntactic sugar
  def target
    self.class.target
  end

  # The default control metadata if none other is specified
  #
  # Used in both class and instance methods
  def self.default_control_metadata
    {
      'reboot_control_metadata' => {
        'log_level' => 'notice',
      },
    }
  end

  def initialize(*args)
    super

    @records = self.class.default_control_metadata
  end

  def exists?
    begin
      require 'deep_merge'

      @records = JSON.parse(File.read(target))

      if @resource[:control_only]
        @records = @records.deep_merge(self.class.default_control_metadata)
      end
    rescue => e
      # Cheap and easy way to ensure that the file gets created and/or fixed if
      # there is something wrong with it.

      Puppet.debug("reboot_notify: #exists? => #{e}")
      return false
    end

    if @resource[:control_only]
      # If this is the control resource, the control components need to match
      #
      # We *may* want to split this out into a separate type in the future

      return @records['reboot_control_metadata']['log_level'] == @resource[:log_level]
    end

    if @records[@resource[:name]]
      return @records[@resource[:name]]['reason'] == @resource[:reason]
    end

    # This is OK, we only want this provider to add records if the file is not
    # there or if the resource is hit with a refresh since reboot notifications
    # always happen because of some event.
    true
  end

  def create
    update_record

    begin
      File.open(target, 'w') { |fh| fh.puts(JSON.pretty_generate(@records)) }
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not create '#{target}': #{e}")
    end
  end

  def destroy
    # This resource is all or nothing so it doesn't make sense to cherry pick
    # items out of the results

    File.unlink(target) if File.exist?(target)
  end

  def update
    update_record

    begin
      File.open(target, 'w') { |fh| fh.puts(JSON.pretty_generate(@records)) }
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not update '#{target}': #{e}")
    end
  end

  # This happens after *all* resources of this type have executed but, being a
  # class method, cannot access any items in the instance methods.
  def self.post_resource_eval
    records = {}
    content = ''

    begin
      content = File.read(target)
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not read file '#{target}': #{e}")
    end

    begin
      records = JSON.parse(content)
    rescue => e
      raise(Puppet::Error, "reboot_notify: Invalid JSON in '#{target}': #{e}")
    end

    current_time = Time.now.tv_sec

    # Need to pull this out of the data structure
    reboot_control_metadata = if records['reboot_control_metadata']
                                records.delete('reboot_control_metadata')
                              else
                                default_control_metadata['reboot_control_metadata']
                              end

    # Purge any records older than our uptime (we rebooted).
    records.delete_if do |_k, v|
      next unless v['updated']

      # If the number of seconds between the time that the record was written
      # and the current time is greater than the system uptime then we should
      # remove the record
      (current_time - v['updated']) > Facter.value(:system_uptime)&.dig('seconds')
    end

    unless records.empty?
      msg = ['System Reboot Required Because:']

      records.each_pair do |k, v|
        next unless v['updated']

        # This is a fail safe for empty 'reasons'
        records[k]['reason'] = 'modified' if records[k]['reason'].nil? || records[k]['reason'].empty?
        msg << ["  #{k} => #{v['reason']}"]
      end

      log_level = reboot_control_metadata['log_level'].to_sym

      begin
        Puppet.send(log_level, msg.join("\n"))
      rescue NoMethodError
        Puppet.warning("Invalid log_level: '#{log_level}'")
        Puppet.notice(msg.join("\n"))
      end
    end

    begin
      reboot_control_hash = { 'reboot_control_metadata' => reboot_control_metadata }
      File.open(target, 'w') { |fh| fh.puts(JSON.pretty_generate(reboot_control_hash.merge(records))) }
    rescue
      raise(Puppet::Error, "reboot_notify: Could not update '#{target}': #{e}")
    end
  end

  private

  def update_record
    if @resource[:control_only]
      @records['reboot_control_metadata']['log_level'] = @resource[:log_level]
    else
      @records[@resource[:name]] = {
        reason: @resource[:reason],
        updated: Time.now.tv_sec,
      }
    end
  end
end
