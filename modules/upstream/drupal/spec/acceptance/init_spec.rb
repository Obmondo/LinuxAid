require 'spec_helper_acceptance'
include TestDependencies

describe 'drupal' do
  specify 'should provision with no errors' do
    apply_manifest(with_test_dependencies("class { 'drupal': }"), :catch_failures => true)
  end

  specify 'should be idempotent' do
    apply_manifest(with_test_dependencies("class { 'drupal': }"), :catch_changes => true)
  end

  describe file('/opt/drupal.org/drush') do
    specify { should be_directory }
  end

  describe file('/opt/drupal.org/drush/drush-8.0.5.phar') do
    specify { should be_file }
    specify { should be_executable }
  end

  describe file('/usr/local/bin/drush') do
    specify { should be_file }
    specify { should be_executable }
  end
end
