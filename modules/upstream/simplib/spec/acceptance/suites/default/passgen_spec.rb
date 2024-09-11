require 'spec_helper_acceptance'
require 'shellwords'

test_name 'simplib::passgen function'
if ENV['BEAKER_fips'] == 'yes'
  hash_algorithms = [ "sha256", "sha512" ]
else
  hash_algorithms = [ "md5", "sha256", "sha512"]
end

shared_examples_for 'a password generator' do |host|
  hash_algorithms.each do |hash|
    (1..5).each do |round|

      # This test does exercise simplib::passgen, but since simplib::passgen
      # does not validate a generated password against any pam settings,
      # (e.g., make sure it passes pwscore), using it for local user passwords
      # IRL may not be advised.
      context "when set user 'testuser#{round}#{hash}' password of hash type == #{hash} on #{host}" do
        let(:manifest) {
          <<-EOS
          # generate the most complex password possible and print out so
          # we have access to it
          $password = simplib::passgen('testuser-#{hash}-#{round}', {'complexity' => 2, 'complex_only' => true})
          notify { "password=<${password}> for testuser-#{hash}-#{round}": }

          # use hash of the generated password for a user's password
          $hashed_password = simplib::passgen('testuser-#{hash}-#{round}', {'hash' => '#{hash}', 'complexity' => 2, 'complex_only' => true})
          user { "testuser#{round}#{hash}":
            shell => "/bin/bash",
            managehome => true,
            password => $password,
          }
          EOS
        }

        it 'should be able to create user with the generated password and then login with that password' do
          result = apply_manifest_on(host, manifest)
          password = result.stdout.match(/password=<(.*)> for testuser/)[1]

          result = on(host, "echo #{Shellwords.escape(password)} | su -c whoami testuser#{round}#{hash}")
          expect(result.stdout).to eql("testuser#{round}#{hash}\n")
        end
      end
    end
  end
end

describe 'simplib::passgen function' do
  context 'libkv mode' do
    let(:hieradata) {{ 'simplib::passgen::libkv' => true }}

    hosts.each do |server|
      context 'test prep' do
        it 'should enable libkv mode for simplib::passgen' do
          set_hieradata_on(server, hieradata)
        end
      end

      context 'password generation' do
        it_behaves_like 'a password generator', server
      end
    end
  end

  context 'legacy mode' do
    let(:hieradata) {{ 'simplib::passgen::libkv' => false }}

    hosts.each do |server|
      context 'test prep' do
        it 'should disable libkv mode for simplib::passgen' do
          set_hieradata_on(server, hieradata)
        end
      end

      context 'password generation' do
        it_behaves_like 'a password generator', server
      end
    end
  end
end
