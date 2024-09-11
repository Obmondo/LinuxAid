require 'spec_helper'

purge = Puppet::Type.type(:purge)


describe purge do

  before :each do


    system_users = {
      "present0" => "100",
      "present1" => "101",
      "present2" => "102",
      "present3" => "103",
      "present4" => "104",
      "present5" => "105",
      "root"     => "0",
      "admin"    => "1",
     }

     catalog_users =  {
       "present0" => "100",
       "misc0"    => "900",
     }


    @system_resources = []
    @catalog_resources = []

    system_users.each { |username,uid|
      res = Puppet::Type.type(:user).new(:name => username, :ensure => :present)
      res.stubs(:to_resource).returns(res)
      res.property(:ensure).stubs(:retrieve).returns(:present)
      res.stubs(:to_hash).returns({:name => username, :uid => uid, :ensure => :present })
      res.property(:ensure).stubs(:set).returns('')
      @system_resources << res 
    }

    catalog_users.each { |username,uid|
      res = Puppet::Type.type(:user).new(:name => username)
      res.provider.stubs(:uid).returns(uid)
      @catalog_resources << res.to_resource 
    }

    
    @catalog = Puppet::Resource::Catalog.new
    @catalog_resources.each do |c|
      @catalog.add_resource(c)
    end

    Puppet::Type.type(:user).stubs(:instances).returns(@system_resources)
    
  end


  context "when initialized" do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user')
      @catalog.add_resource(@purge)
      @purge.generate
      @output = @purge.purged_resources
    end

    it "should do return an array" do
      expect(@output).to be_a(Array)
    end

    it "should only contain user resources" do
      expect do
        @output.map { |r| r.class}.uniq.to eq( [ Puppet::Type::User ] )
      end
    end


    it "should purge the present1,2,3,4,5 users" do
      ['1','2','3','4','5'].each do |n|
        users = @output.map { |r| r.name }
        expect(users).to include("present#{n}")
      end
    end

    it "should not try and manage the user in the catalog" do
      users = @output.map { |r| r.name }
      expect(users).not_to include('present0')
      expect(users).not_to include('misc0')
    end

  end


  ## This fun array is made of
  # [
  #   [
  #     [ 'field', 'operator', 'value' ],
  #     [ if/unless preserve/purge ],
  #     [ if/unless purge/preserve],
  #   ]
  # ]

  test_matrix = [
    [ 
      [ "uid", "==", "102" ],
      [ 'present1','present3','present4','present5','root','admin' ],
      [ 'present2' ]
    ],
    [
      [ "name", "=~", "present.*" ],
      [ "root", "admin" ],
      [ 'present1','present3','present4','present5'],
    ],
    [
      [ "uid", ">=", "101" ],
      [ "root", "admin" ],
      [ 'present1','present3','present4','present5'],
    ],
    [
      [ "uid", "<=", "101" ],
      [ "present2", "present3", "present4", "present5" ],
      [ "present1", "root", "admin" ],
    ],
    [
      [ "uid", ">", "101" ],
      [ "present1", "root", "admin" ],
      [ "present2", 'present3','present4','present5'],
    ],
    [
      [ "uid", "<", "100" ],
      [ "present1", "present2", "present3", "present4", "present5" ],
      [ "root", "admin" ],
    ],

    ## Test for criteria value as array for multi-matching
    [
      [ "name", "==", [ "present2", "present3" ] ],
      [ "present1", "present4", "present5" ],
      [ "present2", "present3" ],
    ]
  ]

  test_matrix.each do |data_set|
    criteria, set_a, set_b = data_set
    [ :if, :unless ].each do |flag|
      case flag
      when :if
        preserve_set = set_a
        purge_set    = set_b
      when :unless
        preserve_set = set_b
        purge_set = set_a
      end


      context "When running #{flag} with #{criteria[1]} #{criteria[2]}" do
        before do
          @purge = Puppet::Type.type(:purge).new(:name => 'user', flag => criteria )
          @catalog.add_resource(@purge)
          @purge.generate
          @output = @purge.purged_resources
          @users = @output.map { |r| r.name }
        end


        ## Add on present0 here, we never purge that user
        [ 'present0', preserve_set ].flatten.each do |u|
          it "should preserve user #{u}" do
            expect(@users).not_to include(u)
          end
        end

        purge_set.each do |u|
          it "should purge user #{u}" do
            expect(@users).to include(u)
          end
        end
      end
    end
  end

  context "When unless supersedes if" do
    before do
      opts = {
        :name => "user",
        :if => [ "uid", "<", "100"],
        :unless => [ "name", "==", "root" ]
      }

      @purge = Puppet::Type.type(:purge).new(opts)
      @catalog.add_resource(@purge)
      @purge.generate
      @output = @purge.purged_resources
      @users = @output.map { |r| r.name }
    end

    it "should purge the admin user" do
      expect(@users).to include("admin")
    end

    it "should not purge the root user" do
      expect(@users).not_to include("root")
    end
  end
            
end

