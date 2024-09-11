require 'puppet_litmus'
require 'puppet_litmus/util'
require 'singleton'
class Helper
  include Singleton
  include PuppetLitmus
end

class CommandFailure < StandardError; end

SHUTDOWN_LOG_LOCATION         = '/tmp/shutdown.log'.freeze
SHUTDOWN_TEMP_LOC             = 'shutdown.original'.freeze
LINUX_SHUTDOWN_SCRIPT         = ['#!/bin/sh', "echo ${@} > #{SHUTDOWN_LOG_LOCATION}"].freeze
SHUTDOWN_SCRIPT_EXPECTED_SHA1 = 'fb5cbae00d9ba7bc7433b46d890c8397f3f23462'.freeze

# On Linux systems, we cannot reliably or consistently cancel the shutdown command. Instead, we will replace the
# shutdown command on $PATH with the script defined in LINUX_SHUTDOWN_SCRIPT, which will output the args passed to it
# from the Agent. We will then verify that these args are what we expect.
def substitute_shutdown_on_path
  $shutdown_path = Helper.instance.run_shell('which shutdown').stdout.chomp
  if Helper.instance.run_shell("test -f #{SHUTDOWN_TEMP_LOC}", expect_failures: true).exit_code == 0
    return if Helper.instance.run_shell("sha1sum #{$shutdown_path} | cut -d ' ' -f 1").stdout.chomp == SHUTDOWN_SCRIPT_EXPECTED_SHA1
  end
  Helper.instance.run_shell("mv #{$shutdown_path} #{SHUTDOWN_TEMP_LOC}")
  LINUX_SHUTDOWN_SCRIPT.each do |line|
    Helper.instance.run_shell("echo '#{line}' >> #{$shutdown_path}")
  end
  Helper.instance.run_shell("chmod +x #{$shutdown_path}")
end

RSpec.configure do |c|
  # Skip tasks tests unless Bolt is available
  c.filter_run_excluding(bolt: true) unless ENV['GEM_BOLT']
  c.include PuppetLitmus::Util
  c.extend PuppetLitmus::Util

  c.before :suite do
    Helper.instance.run_shell('puppet module install puppetlabs-stdlib')
    Helper.instance.run_shell('puppet module install puppetlabs-registry')
    substitute_shutdown_on_path unless os[:family] == 'windows'
  end

  c.after :suite do
    Helper.instance.run_shell("mv #{SHUTDOWN_TEMP_LOC} #{$shutdown_path}") unless os[:family] == 'windows' or $shutdown_path.nil?
  end
end

WINDOWS_SHUTDOWN_ABORT = 'cmd /c shutdown /a'.freeze
# Some versions of ruby and puppet improperly report exit codes
# due to a ruby bug the correct error code 1116, is returned modulo 256 = 92
WINDOWS_SHUTDOWN_NOT_IN_PROGRESS = [1116, 1116 % 256].freeze

# On Windows, we will cancel the shutdown in progress as verification that the agent issued a reboot command.
# On Linux, we will verify the expected args passed to the dummy shutdown script we put in-line.
# TODO: Could capture the time before puppet_apply(manifest) and get the script to output the current time at invocation
# TODO: ...and compare the times. Pass/fail based on an acceptable level of drift not being exceeded.
def reboot_issued_or_cancelled(expected_args=['-r', '+1', 'Puppet', 'is', 'rebooting', 'the', 'computer'])
  if os[:family] == 'windows'
    result = run_shell(WINDOWS_SHUTDOWN_ABORT, expect_failures: true)
    return [0, WINDOWS_SHUTDOWN_NOT_IN_PROGRESS].flatten.include? result.exit_code
  else
    raise 'No args to verify against' if expected_args.empty?
    result = run_shell("cat #{SHUTDOWN_LOG_LOCATION}")
    return result.stdout.chomp.split(' ') == expected_args if result.exit_code == 0
  end
  false
end

def bolt_result_as_hash(result)
  return {} unless result.result
  return result.result if result.result.is_a? Hash
  JSON.parse(result.result.gsub('=>', ':'))
end
