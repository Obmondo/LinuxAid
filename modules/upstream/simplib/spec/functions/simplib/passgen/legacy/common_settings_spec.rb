#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::legacy::common_settings' do
  it "should return legacy passgen's common settings" do
    subject()  # creates vardir for this example block
    expected = {
      'keydir'    => File.join(Puppet.settings[:vardir], 'simp', 'environments',
        scope.lookupvar('::environment'), 'simp_autofiles', 'gen_passwd'),
      'user'      => Etc.getpwuid(Process.uid).name,
      'group'     => Etc.getgrgid(Process.gid).name,
      'dir_mode'  => 0750,
      'file_mode' => 0640
    }

    is_expected.to run.and_return(expected)
  end
end
