# GRUB legacy / 0.9x support for menu entries
#
# Copyright (c) 2016 Trevor Vaughan <tvaughan@onyxpoint.com>
# Licensed under the Apache License, Version 2.0
# Based on work by Dominic Cleal

raise("Missing augeasproviders_core dependency") if Puppet::Type.type(:augeasprovider).nil?
Puppet::Type.type(:grub_menuentry).provide(:grub, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update GRUB menu entries"

  has_feature :grub

  default_file do
    FileTest.exist?("/boot/efi/EFI/redhat/grub.conf") ? "/boot/efi/EFI/redhat/grub.conf" : "/boot/grub/menu.lst"
  end

  lens { 'Grub.lns' }

  confine :feature => :augeas
  commands :grub => 'grub'
  commands :grubby => 'grubby'

  #### Class Methods

  #Pull the kernel options off of the system and arrange them properly
  # into the Array of Arrays.
  #
  # @param aug (Augeas) the Augeas tree object
  # @param path (String) the root entry path
  def self.get_kernel_options(aug, path)
    kernel_options = []

    aug.match("#{path}/kernel/*").each do |kopt|
      kopt_val = aug.get(kopt)
      kopt = kopt.split('/').last.split('[').first

      if kopt_val
        kernel_options << "#{kopt}=#{kopt_val}"
      else
        kernel_options << kopt
      end
    end

    kernel_options
  end

  # Retrieve the list of modules from the GRUB menu entry.
  #
  # @param aug (Augeas) the Augeas tree object
  # @param path (String) the root entry path
  def self.get_modules(aug, path)
    modules = []

    if aug.exists("#{path}/module[1]")

      file_modules = aug.match("#{path}/module")
      file_modules.each do |file_mod|
        # Modules have a full path
        mod_name = "/#{aug.get(file_mod).split('/').last}"

        new_mod = [mod_name]

        aug.match("#{file_mod}/*").each do |mod_opt|
          mod_opt_val = aug.get(mod_opt)
          mod_opt = mod_opt.split('/').last.split('[').first

          if mod_opt_val
            new_mod << "#{mod_opt}=#{mod_opt_val}"
          else
            new_mod << mod_opt
          end
        end

        modules << new_mod
      end
    end

    modules
  end

  def self.instances
    require 'puppetx/augeasproviders_grub/menuentry'

    resources = []

    augopen do |aug|
      menu_entries = aug.match("$target/title")

      menu_entries.each do |pp|
        # Then retrieve all unique values as string (1) or array
        entry_name = aug.get(pp)
        kernel = aug.get("#{pp}/kernel")
        initrd = aug.get("#{pp}/initrd")
        fs_root = aug.get("#{pp}/root")
        default_entry = ((aug.get("$target/default") || '0').to_i + 1)

        modules = self.class.get_modules(aug, pp)

        resource = {
          :name          => entry_name,
          :ensure        => :present,
          :root          => fs_root,
          :default_entry => (pp.split('[').last[0].chr == default_entry),
          :makeactive    => aug.exists("#{pp}/makeactive")
        }

        if kernel
          resource[:kernel] = kernel

          kernel_options = self.class.get_kernel_options(aug, pp)

          if kernel_options && !kernel_options.empty?
            resource[:kernel_options] = kernel_options
          end
        end

        if initrd
          resource[:initrd] = initrd
        end

        if modules && !modules.empty?
          resource[:modules] = modules
        end

        resources << new(resource)
      end
    end

    resources
  end
  #### End Class Methods


  def initialize(*args)
    require 'puppetx/augeasproviders_grub/menuentry'

    @grubby_info = {}
    begin
      grubby_raw = grubby '--info=DEFAULT'

      grubby_raw.each_line do |opt|
        key,val = opt.split('=')

        @grubby_info[key.strip] = val.strip
      end
    rescue Puppet::ExecutionFailure
      @grubby_info = {}
    end

    # Accelerators to reduce code complexity
    @new_kernel_options = []
    @new_modules_options = []

    super(*args)

    # We need to record these here in case they get changed in the future.
    augopen do |aug|
      default_entry_index = ((aug.get("$target/default") || '0').to_i + 1).to_s
      default_entry_path  = %($target/title[#{default_entry_index}])

      @default_entry = {
        :path           => default_entry_path,
        :index          => default_entry_index,
        :kernel_options => self.class.get_kernel_options(aug, default_entry_path),
        :kernel         => @grubby_info['kernel'],
        :initrd         => @grubby_info['initrd']
      }
    end
  end

  def exists?
    augopen do |aug|
      !aug.match(menu_entry_path).empty?
    end
  end

  def create
    # Input Validation
    fail Puppet::Error, '`kernel` is a required property' unless resource[:kernel]
    fail Puppet::Error, '`root` is a required property' unless resource[:root]

    unless resource[:modules]
      fail Puppet::Error, '`initrd` is a required parameter' unless resource[:initrd]
    end

    augopen! do |aug|
      aug.insert('$target/title[1]','title',true)
      aug.set('$target/title[1]',resource[:name])
    end

    # Order matters!
    self.root=(resource[:root])

    # Need to prime this to reduce duplication later
    self.kernel?([],resource[:kernel])
    self.kernel=(resource[:kernel])

    if resource[:kernel_options]
      # Need to prime this to reduce duplication later
      self.kernel_options?([],resource[:kernel_options])
      self.kernel_options=(resource[:kernel_options])
    end

    if resource[:initrd]
      # Need to prime this to reduce duplication later
      self.initrd?([],resource[:initrd])
      self.initrd=(resource[:initrd])
    end

    if resource[:modules]
      # Need to prime this to reduce duplication later
      self.modules?([],resource[:modules])
      self.modules=(resource[:modules])
    end

    # Broken in the lens
    #self.lock=(resource[:lock])
    if resource[:makeactive]
      self.makeactive=(resource[:makeactive])
    end

    if resource[:default_entry]
      self.default_entry=(resource[:default_entry])
    end
  end

  def destroy
    augopen! do |aug|
      aug.rm(menu_entry_path)
    end
  end

  def root
    augopen do |aug|
      aug.get("#{menu_entry_path}/root")
    end
  end

  def root?(is,should)
    is == should
  end

  def root=(newval)
    augopen! do |aug|
      aug.set("#{menu_entry_path}/root", newval)
    end
  end

  def default_entry
    menu_entry_index == @default_entry[:index]
  end

  def default_entry=(newval)
    augopen! do |aug|
      aug.set('$target/default', (menu_entry_index.to_i - 1).to_s)
    end
  end

  def initrd
    augopen do |aug|
      aug.get("#{menu_entry_path}/initrd")
    end
  end

  def initrd?(is,should)
    return true unless should

    @new_initrd = should

    if @new_initrd == ':preserve:'
      @new_initrd = is
      if !@new_initrd || @new_initrd.empty?
        @new_initrd = ':default:'
      end
    end

    if @new_initrd == ':default:'
      @new_initrd = PuppetX::AugeasprovidersGrub::Util.munge_grubby_value(@new_initrd, 'initrd', @grubby_info)
    end

    unless @new_initrd
      raise Puppet::Error, 'Could not find a valid initrd value to set'
    end

    is == @new_initrd
  end

  def initrd=(newval)
    augopen! do |aug|
      aug.set("#{menu_entry_path}/initrd",PuppetX::AugeasprovidersGrub::Util.munge_grubby_value(@new_initrd,'initrd',@grubby_info))
    end
  end

  def kernel
    augopen do |aug|
      aug.get("#{menu_entry_path}/kernel")
    end
  end

  def kernel?(is,should)
    return true unless should

    @new_kernel = should

    if @new_kernel == ':preserve:'
      @new_kernel = is
      if !@new_kernel || @new_kernel.empty?
        @new_kernel = ':default:'
      end
    end

    if @new_kernel == ':default:'
      @new_kernel = PuppetX::AugeasprovidersGrub::Util.munge_grubby_value(@new_kernel, 'kernel', @grubby_info)
    end

    unless @new_kernel
      raise Puppet::Error, 'Could not find a valid kernel value to set'
    end

    is == @new_kernel
  end

  def kernel=(newval)
    augopen! do |aug|
      aug.set("#{menu_entry_path}/kernel",@new_kernel)
    end
  end

  def kernel_options
    augopen do |aug|
      self.class.get_kernel_options(aug, menu_entry_path)
    end
  end

  def kernel_options?(is,should)
    if resource[:add_defaults_on_creation] && should.include?(':preserve:')
      should << ':defaults:'
    end

    default_kernel_options = @default_entry[:kernel_options]
    if resource[:modules]
      # We don't want to pick up any default kernel options if this is a multiboot entry.
      default_kernel_options = {}
    end

    @new_kernel_options = PuppetX::AugeasprovidersGrub::Util.munged_options(is, should, @default_entry[:kernel], default_kernel_options)
    old_options = PuppetX::AugeasprovidersGrub::Util.munged_options(is, ':preserve:', @default_entry[:kernel], @default_entry[:kernel_options])

    old_options == @new_kernel_options
  end

  def kernel_options=(newval)
    new_kernel_options = @new_kernel_options

    default_kernel_options = @default_entry[:kernel_options]
    if resource[:modules]
      # We don't want to pick up any default kernel options if this is a multiboot entry.
      default_kernel_options = {}
    end

    if Array(new_kernel_options).empty?
      new_kernel_options = PuppetX::AugeasprovidersGrub::Util.munged_options([], newval, @default_entry[:kernel], default_kernel_options)
    end

    process_option_line(new_kernel_options,'kernel')
  end

  def modules
    augopen do |aug|
      self.class.get_modules(aug, menu_entry_path)
    end
  end

  def modules?(is,should)
    @new_modules_options = []
    old_options = []

    i = 0
    Array(should).each do |module_set|
      if resource[:add_defaults_on_creation] && module_set.include?(':preserve:')
        module_set << ':defaults:'
      end

      current_val = Array(Array(is)[i])
      @new_modules_options << PuppetX::AugeasprovidersGrub::Util.munged_options(current_val, module_set, @default_entry[:kernel], @default_entry[:kernel_options], true)

      unless current_val.empty?
        old_options << PuppetX::AugeasprovidersGrub::Util.munged_options(current_val,':preserve:', @default_entry[:kernel], @default_entry[:kernel_options], true)
      end

      i += 1
    end

    return old_options == @new_modules_options
  end

  def modules=(newval)
    new_modules_options = @new_modules_options

    if Array(new_modules_options).empty?
      new_modules_options = []
      Array(newval).each do |module_set|
        new_modules_options << PuppetX::AugeasprovidersGrub::Util.munged_options([], module_set, @default_entry[:kernel], @default_entry[:kernel_options])
      end
    end

    process_option_line(new_modules_options,'module')
  end

  def lock=(newval)
    augopen! do |aug|
      if newval == :true
        aug.set("#{menu_entry_path}/lock")
      else
        aug.rm("#{menu_entry_path}/lock")
      end
    end
  end

  def makeactive
    augopen do |aug|
      aug.exists("#{menu_entry_path}/makeactive")
    end
  end

  def makeactive=(newval)
    augopen! do |aug|
      if newval == :true
        aug.set("#{menu_entry_path}/makeactive")
      else
        aug.rm("#{menu_entry_path}/makeactive")
      end
    end
  end

  # Helper Methods
  private
  # Handles 'kernel'-style option lines
  # Probably not foolproof...
  def process_option_line(newval, flavor)
    augopen! do |aug|
      # Get rid of all of them and rewrite them
      if flavor == 'kernel'
        aug.rm("#{menu_entry_path}/#{flavor}/*")
      else
        aug.rm("#{menu_entry_path}/#{flavor}")
      end

      Array(newval).each do |opt_array|
        # Module sections are relatively arbitrary and can have multiple
        # entries.
        unless flavor == 'kernel'
          opt_name = Array(opt_array).shift
          aug.set("#{menu_entry_path}/#{flavor}[last()+1]", opt_name)
        end

        Array(opt_array).each do |base_opts|
          opt,val = base_opts.split('=')

          aug.set("#{menu_entry_path}/#{flavor}[last()]/#{opt}[last()+1]",val)
        end
      end
    end
  end

  def menu_entry_path
    return %($target/title[. = "#{resource[:name]}"])
  end

  def menu_entry_index
    augopen do |aug|
      return aug.match(menu_entry_path).first.split('[').last.chop
    end
  end
end
