require 'spec_helper_acceptance'

test_name 'simplib::caller function'

describe 'simplib::caller function' do
  let(:manifest){
    <<-EOM
    include testmod
    EOM
  }

  hosts.each do |host|
    host_modulepath = puppet_modulepath_on(host).first

    copy_module_to(host, {
      :source             => File.absolute_path(File.join(__dir__, 'files', 'modules', 'testmod')),
      :module_name        => 'testmod',
      :target_module_path => host_modulepath
    })

    it 'should return the correct location' do
      results = apply_manifest_on(host, manifest, :expect_failures => true).output

      expect(results).to match(%r{#{host_modulepath}/testmod/manifests/init.pp}m)
    end
  end
end
