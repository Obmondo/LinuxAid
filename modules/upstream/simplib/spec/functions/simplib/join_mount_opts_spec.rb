#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::join_mount_opts' do
# "tmp_mount_dev_shm": "rw,seclabel,nosuid,nodev,noexec,relatime"
# "tmp_mount_tmp": "rw,seclabel,nosuid,nodev,noexec,relatime,attr2,inode64,noquota"
# "tmp_mount_var_tmp": "rw,seclabel,nosuid,nodev,noexec,relatime,attr2,inode64,noquota"
  context 'without selinux mount options specified' do
    let(:facts) {{ :selinux_current_mode => 'enforcing' }}

    context 'with no mount options overlap' do
      it 'concatenates system and new options' do
        sys_opts = ['bind']
        new_opts = ['noexec','nodev','nosuid']
        exp_out = 'bind,nodev,noexec,nosuid'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end
    end

    context 'with mount options overlap' do
      it 'replaces overlapping system options with new options' do
        sys_opts = ['context=system_u:object_r:usr_tmp_t']
        new_opts = ['context=system_u:object_r:tmp_t']
        exp_out = 'context=system_u:object_r:tmp_t'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end

      it "removes 'no<option>' system options when enabled in new options" do
        sys_opts = ['noexec','nodev','nosuid']
        new_opts = ['rw', 'exec', 'suid']
        exp_out = 'exec,nodev,rw,suid'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end

      it "removes system options when disabled with 'no<option>' in new options" do
        sys_opts = ['rw', 'exec', 'suid']
        new_opts = ['noexec','nodev','nosuid']
        exp_out = 'nodev,noexec,nosuid,rw'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end

      it 'removes "\' in option values that do not contain commas' do
        sys_opts = [ %q(defcontext="'user_u:object_r:insecure_t"') ]
        new_opts = [ %q(context="'system_u:object_r:tmp_t"') ]
        exp_out = 'context=system_u:object_r:tmp_t,defcontext=user_u:object_r:insecure_t'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end

      it 'replaces "\' with " in values containing commas' do
        sys_opts = [%q(context="'system_u:object_r:tmp_t:s0:c127,c456'")]
        new_opts = ['noexec']
        exp_out = 'context="system_u:object_r:tmp_t:s0:c127,c456",noexec'
        is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
      end
    end
  end

  context 'with selinux mount options specified' do

    ['enforcing', 'permissive'].each do |selinux_mode|
      context "with selinux '#{selinux_mode}'" do
        let(:facts) {{ :selinux_current_mode => selinux_mode }}

        ['context', 'fscontext', 'defcontext', 'rootcontext'].each do |context_opt|
          it "removes #{context_opt} when seclabel exits in system options" do
            sys_opts = ['seclabel']
            new_opts = ["#{context_opt}=system_u:object_r:tmp_t"]
            exp_out = 'seclabel'
            is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
          end
        end
      end
    end


    ['disabled', nil].each do |selinux_mode|
      context "with selinux '#{selinux_mode}'" do
        let(:facts) {{ :selinux_current_mode => selinux_mode }}

        ['context', 'fscontext', 'defcontext', 'rootcontext'].each do |context_opt|
          it "removes #{context_opt}" do
            sys_opts = ['rw']
            new_opts = ["#{context_opt}=system_u:object_r:tmp_t"]
            exp_out = 'rw'
            is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
          end
        end

        it 'removes seclabel' do
          sys_opts = ['rw']
          new_opts = ['seclabel']
          exp_out = 'rw'
          is_expected.to run.with_params(sys_opts, new_opts).and_return(exp_out)
        end
      end
    end
  end

end
