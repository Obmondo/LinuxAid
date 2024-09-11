#!/usr/bin/env rspec

require 'spec_helper'

runlevel_type = Puppet::Type.type(:runlevel)

describe runlevel_type do
  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Runlevel.any_instance.stubs(:catalog).returns(@catalog)
  end

  context 'when setting parameters' do
    let(:valid_names){{
      '1'          => '1',
      '2'          => '2',
      '3'          => '3',
      '4'          => '4',
      '5'          => '5',
      'rescue'     => '1',
      'multi-user' => '3',
      'graphical'  => '5'
    }}

    let(:invalid_names){[
      'foo', '0', 'graphical.target'
    ]}

    context ':name' do
      it 'should accept valid values' do
        valid_names.each_pair do |key, value|
          resource = runlevel_type.new(:name => key)
          expect(resource[:name]).to eq(value)
        end
      end

      it 'should reject invalid values' do
        invalid_names.each do |value|
          expect { runlevel_type.new(:name => value) }.to raise_error(/Invalid value/)
        end
      end
    end

    context ':level' do
      it 'should accept valid values' do
        valid_names.each_pair do |key, value|
          resource = runlevel_type.new(
            :name  => '5',
            :level => value
          )

          expect(resource[:level]).to eq(value)
        end
      end

      it 'should reject invalid values' do
        invalid_names.each do |value|
          expect {
            runlevel_type.new(
              :name  => '5',
              :level => value
            )
          }.to raise_error(/Invalid value/)
        end
      end
    end

    context ':transition_timeout' do
      let(:valid_values){[
        '0', '100','1000000'
      ]}

      let(:invalid_values){[
        'bob', '-1'
      ]}

      it 'should accept valid values' do
        valid_values.each do |value|
          resource = runlevel_type.new(
            :name               => '5',
            :transition_timeout => value
          )

          expect(resource[:transition_timeout]).to eq(value.to_i)
        end
      end

      it 'should reject invalid values' do
        invalid_values.each do |value|
          expect {
            runlevel_type.new(
              :name               => '5',
              :transition_timeout => value
            )
          }.to raise_error(/Invalid value/)
        end
      end
    end

    context 'persist' do
      let(:valid_values){[
        'true', 'false', true, false
      ]}

      it 'should accept valid values' do
        valid_values.each do |value|
          resource = runlevel_type.new(
            :name    => '5',
            :persist => value
          )

          expect(resource[:persist]).to eq("#{value}".to_sym)
        end
      end
    end
  end
end

