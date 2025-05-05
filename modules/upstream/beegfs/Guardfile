# frozen_string_literal: true

notification :off

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
end
