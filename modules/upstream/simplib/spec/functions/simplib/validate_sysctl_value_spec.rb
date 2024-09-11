require 'spec_helper'

describe 'simplib::validate_sysctl_value' do

  context 'kernel.core_pattern' do
    context 'valid config' do
      it 'validates a setting that is a filename' do
        is_expected.to run.with_params('kernel.core_pattern','/var/core/%u_%g_%p_%t_%h_%e.core')
      end

      it 'validates a setting to pipe core to an fully qualified path' do
        is_expected.to run.with_params('kernel.core_pattern','| /usr/sbin/my_core_dump_program %p')
      end

      it 'accepts setting for which it does not have a validation routine' do
        is_expected.to run.with_params('net.ipv4.tcp_available_congestion_control','oops')
      end

    end

    context 'invalid config' do
      it 'rejects a setting that is too long' do
        is_expected.to run.with_params('kernel.core_pattern', '/var/core/'+ "x"*120).and_raise_error(
         /Values for kernel.core_pattern must be less than 129 characters/ )
      end

      it 'rejects a setting that is pipe to an executable that does not have a fully-qualified path' do
        is_expected.to run.with_params('kernel.core_pattern', '| my_core_dump_program %p').and_raise_error(
         /Piped commands for kernel.core_pattern must have an absolute path/ )
      end
    end
  end

  context 'fs.inotify.max_user_watches' do
    let(:facts){{
      :architecture  => 'x86_64',
      :memorysize_mb => 20
    }}

    context 'valid config' do
      it 'validates a setting that is a positive integer that does not exceed the memory limit' do
        is_expected.to run.with_params('fs.inotify.max_user_watches', 20)
      end
    end

    context 'invalid config' do
      invalid_values = [
        0,
        'Invalid',
        { :bad => 'stuff' },
        [ 'Also', 'Bad' ]
      ]

      invalid_values.each do |value|
        it "rejects #{value}" do
          is_expected.to run.with_params('fs.inotify.max_user_watches', value).and_raise_error(
            /fs.inotify.max_user_watches cannot be #{Regexp.escape(value.to_s)}/ )
        end
      end

      context 'x86_64' do
        it 'rejects items that exceed the memory limit' do
          is_expected.to run.with_params('fs.inotify.max_user_watches', 20480).and_raise_error(
            /fs.inotify.max_user_watches set to 20480 would exceed system RAM/ )
        end
      end

      context 'i686' do
        let(:facts){{
          :architecture  => 'i686',
          :memorysize_mb => 20
        }}

        it 'rejects items that exceed the memory limit' do
          is_expected.to run.with_params('fs.inotify.max_user_watches', 40960).and_raise_error(
            /fs.inotify.max_user_watches set to 40960 would exceed system RAM/ )
        end
      end
    end
  end
end
