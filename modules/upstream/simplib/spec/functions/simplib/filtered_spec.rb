#!/usr/bin/env ruby -S rspec
# vim: set expandtab ts=2 sw=2:
require 'spec_helper'
require 'semantic_puppet'
puppetver = SemanticPuppet::Version.parse(Puppet.version)
requiredver = SemanticPuppet::Version.parse("4.9.0")
if (puppetver > requiredver)
  describe 'simplib::filtered' do
    shared_options = {
      "function" => "simplib::mock_data",
    }
    context  "using data_hash dispatch" do
      it 'should run successfully' do
        result = subject.execute(shared_options.dup.merge({"path" => "nofile"}), Puppet::Pops::Lookup::Context.new('rp_env', 'simplib'))
        expect(result).to eql({})
      end
      {
        "with no filters" => {
          "all_results" => true,
          "filter" => [],
        },
        "with simple filter" => {
          "all_results" => false,
          "filter" => [
            'profiles::test2::variable',
            'apache::sync',
            'user::root_password',
          ],
        },
        "with regex filter" => {
          "all_results" => false,
          "filter" => [
            '^profiles::test2::.*$',
            '^apache::.*$',
            '^user.*root_password$',
          ],
        },
      }.each do |key, value|
            context key do
              {
                "with path = 'nofile'" => {
                  "path" => "nofile",
                  "retval" => {},
                },
                "with path = '/path/1'" => {
                  "path" => "/path/1",
                  "retval" => {"profiles::test1::variable"=>"goodvar", "profiles::test2::variable"=>"badvar", "profiles::test::test1::variable"=>"goodvar", "apache::sync"=>"badvar", "user::root_password"=>"badvar"},
                },
                "with path = '/path/2'" => {
                  "path" => "/path/2",
                  "retval" => {"profiles::test1::variable"=>"goodvar", "profiles::test2::variable"=>"badvar", "profiles::test::test1::variable"=>"goodvar"},
                },
              }.each do |name, data|
                  context name do
                    if (value["all_results"] == true)
                      it 'should return all results' do
                        result = subject.execute(shared_options.dup.merge({"path" => data["path"], "filter" => value["filter"]}), Puppet::Pops::Lookup::Context.new('rp_env', 'simplib'))
                        expect(result).to eql(data["retval"])
                      end
                    end
                    if (value["all_results"] == false)
                      it 'should not return all results' do
                        result = subject.execute(shared_options.dup.merge({"path" => data["path"], "filter" => value["filter"]}), Puppet::Pops::Lookup::Context.new('rp_env', 'simplib'))
                        if (data["retval"] == {})
                          expect(result).to eql(data["retval"])
                        else
                          expect(result).to_not eql(data["retval"])
                        end
                      end
                    end
                  end
                end
            end
          end
    end
  end
end
