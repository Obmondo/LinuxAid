require 'spec_helper'

describe 'kmod::load', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        data = if facts[:os]['name'] == 'Archlinux'
                 { augeasversion: '1.2.0', service_provider: 'systemd' }
               else
                 { augeasversion: '1.2.0' }
               end
        facts.merge(data)
      end

      context 'with ensure set to present' do
        let(:params) { { ensure: 'present', file: '/foo/bar' } }

        it { is_expected.to contain_kmod__load('foo') }
        it {
          is_expected.to contain_exec('modprobe foo')
            .with('unless' => "egrep -q '^foo ' /proc/modules")
        }

        context 'when on systemd' do
          let(:facts) do
            facts.merge(service_provider: 'systemd')
          end

          it {
            is_expected.to contain_file('/etc/modules-load.d/foo.conf')
              .with('ensure' => 'present',
                    'mode' => '0644',
                    'content' => "# This file is managed by the puppet kmod module.\nfoo\n")
          }
        end

        context 'when not on systemd' do
          case facts[:osfamily]
          when 'Debian'
            it {
              is_expected.to contain_augeas('Manage foo in /foo/bar')
                .with('incl' => '/foo/bar',
                      'lens'    => 'Modules.lns',
                      'changes' => "clear 'foo'")
            }
          when 'Suse'
            it {
              is_expected.to contain_augeas('sysconfig_kernel_MODULES_LOADED_ON_BOOT_foo')
                .with('incl' => '/foo/bar',
                      'lens'    => 'Shellvars_list.lns',
                      'changes' => "set MODULES_LOADED_ON_BOOT/value[.='foo'] 'foo'")
            }
          when 'RedHat'
            it {
              is_expected.to contain_file('/etc/sysconfig/modules/foo.modules')
                .with('ensure' => 'present',
                      'mode'    => '0755',
                      'content' => %r{exec /sbin/modprobe foo > /dev/null 2>&1})
            }
          end
        end
      end

      context 'with ensure set to absent' do
        let(:params) { { ensure: 'absent', file: '/foo/bar' } }

        it { is_expected.to contain_kmod__load('foo') }
        it {
          is_expected.to contain_exec('modprobe -r foo')
            .with('onlyif' => "egrep -q '^foo ' /proc/modules")
        }

        context 'when on systemd' do
          let(:facts) do
            facts.merge(service_provider: 'systemd')
          end

          it {
            is_expected.to contain_file('/etc/modules-load.d/foo.conf')
              .with('ensure' => 'absent',
                    'mode' => '0644',
                    'content' => "# This file is managed by the puppet kmod module.\nfoo\n")
          }
        end

        context 'when not on systemd' do
          case facts[:osfamily]
          when 'Debian'
            it {
              is_expected.to contain_augeas('Manage foo in /foo/bar')
                .with('incl' => '/foo/bar',
                      'lens'    => 'Modules.lns',
                      'changes' => "rm 'foo'")
            }
          when 'Suse'
            it {
              is_expected.to contain_augeas('sysconfig_kernel_MODULES_LOADED_ON_BOOT_foo')
                .with('incl' => '/foo/bar',
                      'lens'    => 'Shellvars_list.lns',
                      'changes' => "rm MODULES_LOADED_ON_BOOT/value[.='foo']")
            }
          when 'RedHat'
            it {
              is_expected.to contain_file('/etc/sysconfig/modules/foo.modules')
                .with('ensure' => 'absent',
                      'mode'    => '0755',
                      'content' => %r{exec /sbin/modprobe foo > /dev/null 2>&1})
            }
          end
        end
      end
    end
  end
end
