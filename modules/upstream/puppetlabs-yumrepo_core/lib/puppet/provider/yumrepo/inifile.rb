require 'puppet/util/inifile'

module Puppet::Provider::Yumrepo # rubocop:disable Style/ClassAndModuleChildren
  module IniConfig
    class Section < Puppet::Util::IniConfig::Section; end

    # Examines a file on disk and identifies whether a section exists.
    class PhysicalFile < Puppet::Util::IniConfig::PhysicalFile
      def store
        unlinked = false
        if @destroy_empty && (sections.empty? || sections.all?(&:destroy?))
          ::File.unlink(@file)
          unlinked = true
        elsif sections.any?(&:dirty?)
          text = self.format
          @filetype.write(text)
        end
        sections.each(&:mark_clean)
        unlinked
      end

      private

      def section_exists?(name)
        section = @file_collection.get_section(name) if @file_collection
        if get_section(name)
          true
        elsif section && !section.destroy?
          true
        else
          false
        end
      end
    end

    # Creates a collection of new files on disk.
    class FileCollection < Puppet::Util::IniConfig::FileCollection
      def store
        @files.delete_if do |_, file|
          file.store
        end
      end

      private

      # Create a new physical file and set required attributes on that file.
      def new_physical_file(file)
        @files[file] = PhysicalFile.new(file, destroy_empty: true)
        @files[file].file_collection = self
        @files[file]
      end
    end
    File = FileCollection
  end
end

Puppet::Type.type(:yumrepo).provide(:inifile) do
  desc <<-EOD
    Manage yum repo configurations by parsing yum INI configuration files.

    ### Fetching instances

    When fetching repo instances, directory entries in '/etc/yum/repos.d',
    '/etc/yum.repos.d', and the directory optionally specified by the reposdir
    key in '/etc/yum.conf' will be checked. If a given directory does not exist it
    will be ignored. In addition, all sections in '/etc/yum.conf' aside from
    'main' will be created as sections.

    ### Storing instances

    When creating a new repository, a new section will be added in the first
    yum repo directory that exists. The custom directory specified by the
    '/etc/yum.conf' reposdir property is checked first, followed by
    '/etc/yum/repos.d', and then '/etc/yum.repos.d'. If none of these exist, the
    section will be created in '/etc/yum.conf'.
  EOD

  PROPERTIES = Puppet::Type.type(:yumrepo).validproperties

  # Retrieve all providers based on existing yum repositories
  #
  # @api public
  # @return [Array<Puppet::Provider>] providers generated from existing yum
  #   repository definitions.
  def self.instances
    instances = []

    virtual_inifile.each_section do |section|
      # Ignore the 'main' section in yum.conf since it's not a repository.
      next if section.name == 'main'

      attributes_hash = { name: section.name, target: section.file, ensure: :present, provider: :yumrepo }

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
  # @param resources [Array<Puppet::Type::Yumrepo>] Resources to prefetch.
  # @return [void]
  def self.prefetch(resources)
    repos = instances
    resources.each_key do |name|
      provider = repos.find { |repo| repo.name == name }
      if provider
        resources[name].provider = provider
      end
    end
  end

  # Return a list of existing directories that could contain repo files.
  #
  # @api private
  # @param conf [String] Configuration file to look for directories in.
  # @param dirs [Array<String>] Default locations for yum repos.
  # @return [Array<String>] All present directories that may contain yum repo configs.
  def self.reposdir(conf = '/etc/yum.conf', dirs = ['/etc/yum.repos.d', '/etc/yum/repos.d'])
    reposdir = find_conf_value('reposdir', conf)
    # Use directories in reposdir if they are set instead of default
    if reposdir
      # Follow the code from the yum/config.py
      reposdir.tr!("\n", ' ')
      reposdir.tr!(',', ' ')
      dirs = reposdir.split
    end
    dirs.select! { |dir| Puppet::FileSystem.exist?(dir) }
    if dirs.empty?
      Puppet.debug('No yum directories were found on the local filesystem')
    end

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
  def self.find_conf_value(value, conf = '/etc/yum.conf')
    return unless Puppet::FileSystem.exist?(conf)

    file = Puppet::Provider::Yumrepo::IniConfig::PhysicalFile.new(conf)
    file.read
    main = file.get_section('main')
    main ? main[value] : nil
  end

  # Enumerate all files that may contain yum repository configs.
  # '/etc/yum.conf' is always included.
  #
  # @api private
  # @return [Array<String>
  def self.repofiles
    files = ['/etc/yum.conf']
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
  # @return [Puppet::Provider::Yumrepo::IniConfig::File] The virtual inifile representing
  #   multiple real files.
  def self.virtual_inifile
    unless @virtual
      @virtual = Puppet::Provider::Yumrepo::IniConfig::File.new
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
    PROPERTIES.include?(key)
  end

  # Return an existing INI section or create a new section in the default location
  #
  # The default location is determined based on what yum repo directories
  # and files are present. If /etc/yum.conf has a value for 'reposdir' then that
  # is preferred. If no such INI property is found then the first default yum
  # repo directory that is present is used. If no default directories exist then
  # /etc/yum.conf is used.
  #
  # @param name [String] Section name to lookup in the virtual inifile.
  # @return [Puppet::Provider::Yumrepo::IniConfig::Section] The IniConfig section
  def self.section(name, target)
    path = repo_path(name, target)
    result = nil
    old_section = nil
    virtual_inifile.each_section do |section|
      if section.name.eql?(name)
        if target.nil? || target.eql?(:absent) || section.file.eql?(path)
          result = section
        else
          old_section = section
          section.destroy = true
        end
      end
    end
    # Create a new section if not found.
    unless result
      result = virtual_inifile.add_section(name, path)
      # Copy section from old target if found.
      old_section&.entries&.each { |entry| result.add_line(entry) }
    end
    result
  end

  # Save all yum repository files and force the mode to 0644
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
      resource.info _('changing mode of %{file} from %{current_mode} to %{target_mode}') %
                    { file:, current_mode: '%03o' % current_mode, target_mode: '%03o' % target_mode }
      Puppet::FileSystem.chmod(target_mode, file)
    end
  end

  def self.repo_path(name, target)
    dirs = reposdir
    path = if dirs.empty?
             # If no repo directories are present, default to using yum.conf.
             unless target.nil? || target.eql?(:absent)
               Puppet.debug("Using /etc/yum.conf instead of target #{target}")
             end
             '/etc/yum.conf'
           # The ordering of reposdir is [defaults, custom], and we want to use
           # the custom directory if present.else
           elsif target.nil? || target.eql?(:absent)
             File.join(dirs.last, "#{name}.repo")
           else
             parent = Puppet::FileSystem.dir_string(target)
             basename = Puppet::FileSystem.basename_string(target)
             suffix = target.end_with?('.repo') ? '' : '.repo'
             if parent == basename
               File.join(dirs.last, "#{target}#{suffix}")
             elsif dirs.include?(parent)
               "#{target}#{suffix}"
             else
               Puppet.debug("Parent directory of #{target} not a valid yum directory.")
               File.join(dirs.last, "#{basename}#{suffix}")
             end
           end
    path
  end

  # Create a new section for the given repository and set all the specified
  # properties in the section.
  #
  # @api public
  # @return [void]
  def create
    @property_hash[:ensure] = :present
    self.target = self.class.repo_path(name, @resource[:target]) unless @resource[:target].eql?(:absent)

    # Check to see if the file that would be created in the
    # default location for the yumrepo already exists on disk.
    # If it does, read it in to the virtual inifile
    path = self.class.repo_path(name, target)
    self.class.virtual_inifile.read(path) if Puppet::FileSystem.file?(path)

    # We fetch a list of properties from the type, then iterate
    # over them, avoiding ensure.  We're relying on .should to
    # check if the property has been set and should be modified,
    # and if so we set it in the virtual inifile.
    PROPERTIES.each do |property|
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
    @property_hash[:ensure] == :present and (@resource[:target].eql?(:absent) or @property_hash[:target] == self.class.repo_path(name, @resource[:target]))
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
  PROPERTIES.each do |property|
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

  # Map the yumrepo 'descr' type property to the 'name' INI property.
  def descr
    unless @property_hash.key?(:descr)
      @property_hash[:descr] = current_section['name']
    end
    value = @property_hash[:descr]
    value.nil? ? :absent : value
  end

  def descr=(value)
    value = ((value == :absent) ? nil : value)
    current_section['name'] = value
    @property_hash[:descr] = value
  end

  def target
    unless @property_hash.key?(:target)
      @property_hash[:target] = self.class.repo_path(name, nil)
    end
    value = @property_hash[:target]
    value.nil? ? :absent : value
  end

  def target=(value)
    @property_hash[:target] = value
  end

  private

  def get_property(property)
    unless @property_hash.key?(property)
      @property_hash[property] = current_section[property.to_s]
    end
    value = @property_hash[property]
    value.nil? ? :absent : value
  end

  def set_property(property, value)
    value = ((value == :absent) ? nil : value)
    current_section[property.to_s] = value
    @property_hash[property] = value
  end

  def section(name)
    self.class.section(name, target)
  end

  def current_section
    self.class.section(name, target)
  end
end
