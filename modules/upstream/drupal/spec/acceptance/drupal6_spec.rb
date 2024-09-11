require 'spec_helper_acceptance'
include TestDependencies

describe 'drupal-6.x' do
  pp = <<-EOS
    # test manifest
    class { 'drupal': }

    drupal::site { 'drupal-6.x':
      core_version => '6.33',
      modules      => {
        'cck'   => {
          'download' => {
            'type' => 'file',
            'url'  => 'http://ftp.drupal.org/files/projects/cck-6.x-2.9.tar.gz',
            'md5'  => '9e30f22592b7ecf08d020e0c626efc5b',
          },
        },
        'views' => '2.16',
      },
      themes       => {
        'marinelli' => {
          'download' => {
            'type'     => 'git',
            'url'      => 'git://git.drupal.org/project/marinelli.git',
            'revision' => 'fef7745f64541cbe8c746167d3fe37dca133b87b',
          },
        },
        'zen'   => '2.1',
      },
    }
  EOS

  specify 'should provision with no errors' do
    apply_manifest(with_test_dependencies(pp), :catch_failures => true)
  end

  specify 'should be idempotent' do
    apply_manifest(with_test_dependencies(pp), :catch_changes => true)
  end

  describe file('/etc/drush/drupal-6.x.make') do
    specify { should be_file }
  end

  describe file('/var/www/drupal-6.x') do
    specify { should be_directory }
  end

  describe file('/var/www/drupal-6.x/modules/system/system.info') do
    its(:content) { should match /version = "6.33"/ }
  end

  describe file('/var/www/drupal-6.x/sites/all/modules/cck/content.info') do
    its(:content) { should match /version = "6.x-2.9"/ }
  end

  describe file('/var/www/drupal-6.x/sites/all/modules/views/views.info') do
    its(:content) { should match /version = "6.x-2.16"/ }
  end

  describe file('/var/www/drupal-6.x/sites/all/themes/marinelli/marinelli.info') do
    its(:content) { should match /version = "6.x-1.7"/ }
  end

  describe file('/var/www/drupal-6.x/sites/all/themes/zen/zen.info') do
    its(:content) { should match /version = "6.x-2.1"/ }
  end
end
