require 'spec_helper_acceptance'

# a fixed order is required in order to cleanup created jobs -- we are relying
# on existing state as a performance optimization.
describe 'jenkins_job', order: :defined do
  let(:test_build_job) do
    example = <<'EOS'
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>test job</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>/usr/bin/true</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOS
    # escape single quotes for puppet
    example.gsub("'", %q(\\\'))
  end

  let(:test_folder_job) do
    example = <<'EOS'
<?xml version="1.0" encoding="UTF-8"?><com.cloudbees.hudson.plugins.folder.Folder plugin="cloudbees-folder@5.5">
  <properties/>
  <views>
    <hudson.model.AllView>
      <owner class="com.cloudbees.hudson.plugins.folder.Folder" reference="../../.."/>
      <name>All</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
  </views>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <healthMetrics>
    <com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric/>
  </healthMetrics>
  <icon class="com.cloudbees.hudson.plugins.folder.icons.StockFolderIcon"/>
</com.cloudbees.hudson.plugins.folder.Folder>
EOS
    # escape single quotes for puppet
    example.gsub("'", %q(\\\'))
  end

  include_context 'jenkins'

  context 'ensure =>' do
    context 'present' do
      it 'works with no errors' do
        pp = base_manifest + <<-EOS
          jenkins_job { 'foo':
            ensure => present,
            config => \'#{test_build_job}\',
          }
        EOS

        # XXX idempotency is broken
        apply(pp, catch_failures: true)
      end

      describe file('/var/lib/jenkins/jobs/foo/config.xml') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'jenkins' }
        it { is_expected.to be_grouped_into 'jenkins' }
        it { is_expected.to be_mode 644 }
        it { is_expected.to contain '<description>test job</description>' }
      end
    end # 'present' do

    context 'absent' do
      it 'works with no errors and idempotently' do
        pp = base_manifest + <<-EOS
          jenkins_job { 'foo':
            ensure => absent,
          }
        EOS

        apply(pp, catch_failures: true)
        apply(pp, catch_changes: true)
      end

      describe file('/var/lib/jenkins/jobs/foo/config.xml') do
        it { is_expected.not_to exist }
      end
    end # 'absent' do
  end # 'ensure =>' do

  context 'cloudbees-folder plugin' do
    let(:manifest) do
      base_manifest + <<-EOS
        jenkins::plugin { 'cloudbees-folder': }
      EOS
    end

    context 'nested folders' do
      context 'create' do
        it 'works with no errors' do
          pp = manifest + <<-EOS
            jenkins_job { 'foo':
              ensure => present,
              config => \'#{test_folder_job}\',
            }

            jenkins_job { 'foo/bar':
              ensure => present,
              config => \'#{test_folder_job}\',
            }

            jenkins_job { 'foo/bar/baz':
              ensure => present,
              config => \'#{test_build_job}\',
            }
          EOS

          # XXX idempotency is broken
          apply(pp, catch_failures: true)
        end

        %w[
          /var/lib/jenkins/jobs/foo/config.xml
          /var/lib/jenkins/jobs/foo/jobs/bar/config.xml
        ].each do |config|
          describe file(config) do
            it { is_expected.to be_file }
            it { is_expected.to be_owned_by 'jenkins' }
            it { is_expected.to be_grouped_into 'jenkins' }
            it { is_expected.to be_mode 644 }
            it { is_expected.to contain 'cloudbees-folder' }
          end
        end

        describe file('/var/lib/jenkins/jobs/foo/jobs/bar/jobs/baz/config.xml') do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by 'jenkins' }
          it { is_expected.to be_grouped_into 'jenkins' }
          it { is_expected.to be_mode 644 }
          it { is_expected.to contain '<description>test job</description>' }
        end
      end # create

      context 'delete' do
        it 'works with no errors and idempotently' do
          pp = manifest + <<-EOS
            jenkins_job { 'foo': ensure => absent }
            jenkins_job { 'foo/bar': ensure => absent }
            jenkins_job { 'foo/bar/baz': ensure => absent }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        %w[
          /var/lib/jenkins/jobs/foo/config.xml
          /var/lib/jenkins/jobs/foo/jobs/bar/config.xml
          /var/lib/jenkins/jobs/foo/jobs/bar/jobs/baz/config.xml
        ].each do |config|
          describe file(config) { it { is_expected.not_to exist } }
        end
      end # delete
    end # nested folders

    context 'convert existing job to folder' do
      it 'works with no errors' do
        skip # travis is running the beaker tests really slow...
        pending('CLI update-job command is unable to handle the conversion')

        pp = manifest + <<-EOS
          jenkins_job { 'foo':
            ensure => present,
            config => \'#{test_build_job}\',
          }
        EOS

        apply(pp, catch_failures: true)

        pp = manifest + <<-EOS
          jenkins_job { 'foo':
            ensure => present,
            config => \'#{test_folder_job}\',
          }
        EOS

        apply2(pp)

        # only for cleanup
        pp = manifest + <<-EOS
          jenkins_job { 'foo': ensure => absent }
        EOS

        apply2(pp)
      end
    end # convert existing job to folder
  end # cloudbees-folder
end # jenkins_job
