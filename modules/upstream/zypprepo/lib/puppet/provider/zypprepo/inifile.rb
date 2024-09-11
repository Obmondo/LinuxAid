# frozen_string_literal: true

# Description of zypper repositories
require 'puppet/util/inifile'

Puppet::Type.type(:zypprepo).provide(:inifile) do
  desc <<-EOD
    Manage zypper repo configurations by parsing zypper INI configuration files.

    ### Fetching instances
    When fetching repo instances, directory entries in '/etc/zypp/repos.d',
    and the directory optionally specified by the reposdir key in '/etc/zypp/zypp.conf'
    will be checked. If a given directory does not exist it will be ignored.
    In addition, all sections in '/etc/zypp/zypp.conf' aside from
    'main' will be created as sections.

    ### Storing instances
    When creating a new repository, a new section will be added in the first
    zypper repo directory that exists. The custom directory specified by the
    '/etc/zypp/zypp.conf' reposdir property is checked first, followed by
    '/etc/zypp/repos.d'.
  EOD

  ZYPPREPO_PROPERTIES = Puppet::Type.type(:zypprepo).validproperties

  # Retrieve all providers based on existing zypper repositories
  #
  # @api public
  # @return [Array<Puppet::Provider>] providers generated from existing zypper
  #   repository definitions.
  def self.instances
    instances = []

    virtual_inifile.each_section do |section|
      # Ignore the 'main' section in zypp.conf since it's not a repository.
      next if section.name == 'main'

      attributes_hash = { name: section.name, ensure: :present, provider: :zypprepo }

      section.entries.each do |key, value|
        key = key.to_sym
        if valid_property?(key)
          attributes_hash[key] = value
        elsif key == :name
          attributes_hash[:descr] = value
        end
      end
      instances << new(attributes_hash)
    end

    instances
  end

  # Match catalog type instances to provider instances.
  #
  # @api public
  # @param resources [Array<Puppet::Type::Zypprepo>] Resources to prefetch.
  # @return [void]
  def self.prefetch(resources)
    repos = instances
    resources.each_key do |name|
      provider = repos.find { |repo| repo.name == name }
      resources[name].provider = provider if provider
    end
  end

  #
  # @api private
  # @param conf [String] Configuration file to look for directories in.
  # @param dirs [Array<String>] Default locations for zypper repos.
  # @return [Array<String>] All present directories that may contain zypper repo configs.
  def self.reposdir(conf = '/etc/zypp/zypp.conf', dirs = ['/etc/zypp/repos.d'])
    reposdir = find_conf_value('reposdir', conf)
    # Use directories in reposdir if they are set instead of default
    if reposdir
      # Follow the code from the yumrepo provider
      reposdir_stripped = reposdir.strip.tr("\n", ' ').tr(',', ' ')
      dirs = reposdir_stripped.split
    end
    dirs.select! { |dir| Puppet::FileSystem.exist?(dir) }
    Puppet.debug('No zypper directories were found on the local filesystem') if dirs.empty?

    dirs
  end

  # Used for testing only
  # @api private
  def self.clear
    @virtual = nil
  end

  # Helper method to look up specific values in ini style files.
  #
  # @api private
  # @param value [String] Value to look for in the configuration file.
  # @param conf [String] Configuration file to check for value.
  # @return [String] The value of a looked up key from the configuration file.
  def self.find_conf_value(value, conf = '/etc/zypp/zypp.conf')
    return unless Puppet::FileSystem.exist?(conf)

    file = Puppet::Util::IniConfig::PhysicalFile.new(conf)
    file.read
    main = file.get_section('main')
    main ? main[value] : nil
  end

  # Enumerate all files that may contain zypper repository configs.
  #
  # @api private
  # @return [Array<String>]
  def self.repofiles
    files = []
    reposdir.each do |dir|
      Dir.glob("#{dir}/*.repo").each do |file|
        files << file
      end
    end

    files
  end

  # Build a virtual inifile by reading in numerous .repo files into a single
  # virtual file to ease manipulation.
  # @api private
  # @return [Puppet::Util::IniConfig::File] The virtual inifile representing
  #   multiple real files.
  def self.virtual_inifile
    unless @virtual
      @virtual = Puppet::Util::IniConfig::File.new
      repofiles.each do |file|
        @virtual.read(file) if Puppet::FileSystem.file?(file)
      end
    end
    @virtual
  end

  # Is the given key a valid type property?
  #
  # @api private
  # @param key [String] The property to look up.
  # @return [Boolean] Returns true if the property is defined in the type.
  def self.valid_property?(key)
    ZYPPREPO_PROPERTIES.include?(key)
  end

  # Return an existing INI section or create a new section in the default location
  #
  # The default location is determined based on what zypper repo directories
  # and files are present. If /etc/zypp/zypper.conf has a value for 'reposdir' then that
  # is preferred. If no such INI property is found then the first default zypper
  # repo directory that is present is used.
  #
  # @param name [String] Section name to lookup in the virtual inifile.
  # @return [Puppet::Util::IniConfig] The IniConfig section
  def self.section(name)
    result = virtual_inifile[name]
    # Create a new section if not found.
    unless result
      path = repo_path(name)
      result = virtual_inifile.add_section(name, path)
    end
    result
  end

  # Save all zypper repository files and force the mode to 0644
  # @api private
  # @return [void]
  def self.store(resource)
    inifile = virtual_inifile
    inifile.store

    target_mode = 0o644
    inifile.each_file do |file|
      next unless Puppet::FileSystem.exist?(file)

      current_mode = Puppet::FileSystem.stat(file).mode & 0o777
      next if current_mode == target_mode

      resource.info format(_('changing mode of %{file} from %{current_mode} to %{target_mode}'), file: file, current_mode: format('%03o', current_mode), target_mode: format('%03o', target_mode))
      Puppet::FileSystem.chmod(target_mode, file)
    end
  end

  def self.repo_path(name)
    dirs = reposdir
    if dirs.empty?
      # If no repo directories are present, default to using /etc/zypp/repos.d.
      '/etc/zypp/repos.d'
    else
      # The ordering of reposdir is [defaults, custom], and we want to use
      # the custom directory if present.
      File.join(dirs.last, "#{name}.repo")
    end
  end

  # Create a new section for the given repository and set all the specified
  # properties in the section.
  #
  # @api public
  # @return [void]
  def create
    @property_hash[:ensure] = :present

    # Check to see if the file that would be created in the
    # default location for the zypprepo already exists on disk.
    # If it does, read it in to the virtual inifile
    path = self.class.repo_path(name)
    self.class.virtual_inifile.read(path) if Puppet::FileSystem.file?(path)

    # We fetch a list of properties from the type, then iterate
    # over them, avoiding ensure.  We're relying on .should to
    # check if the property has been set and should be modified,
    # and if so we set it in the virtual inifile.
    ZYPPREPO_PROPERTIES.each do |property|
      next if property == :ensure

      value = @resource.should(property)
      send("#{property}=", value) if value
    end
  end

  # Does the given repository already exist?
  #
  # @api public
  # @return [Boolean]
  def exists?
    @property_hash[:ensure] == :present
  end

  # Mark the given repository section for destruction.
  #
  # The actual removal of the section will be handled by {#flush} after the
  # resource has been fully evaluated.
  #
  # @api public
  # @return [void]
  def destroy
    # Flag file for deletion on flush.
    current_section.destroy = true

    @property_hash.clear
  end

  # Finalize the application of the given resource.
  #
  # @api public
  # @return [void]
  def flush
    self.class.store(self)
  end

  # Generate setters and getters for our INI properties.
  ZYPPREPO_PROPERTIES.each do |property|
    # The ensure property uses #create, #exists, and #destroy we can't generate
    # meaningful setters and getters for this
    next if property == :ensure

    define_method(property) do
      get_property(property)
    end

    define_method("#{property}=") do |value|
      set_property(property, value)
    end
  end

  # Map the zypprepo 'descr' type property to the 'name' INI property.
  def descr
    @property_hash[:descr] = current_section['name'] unless @property_hash.key?(:descr)
    value = @property_hash[:descr]
    value.nil? ? :absent : value
  end

  def descr=(value)
    value = (value == :absent ? nil : value)
    current_section['name'] = value
    @property_hash[:descr] = value
  end

  private

  def get_property(property)
    @property_hash[property] = current_section[property.to_s] unless @property_hash.key?(property)
    value = @property_hash[property]
    value.nil? ? :absent : value
  end

  def set_property(property, value)
    value = (value == :absent ? nil : value)
    current_section[property.to_s] = value
    @property_hash[property] = value
  end

  def section(name)
    self.class.section(name)
  end

  def current_section
    self.class.section(name)
  end
end
