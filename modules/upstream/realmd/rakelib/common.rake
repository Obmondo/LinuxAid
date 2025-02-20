PuppetLint.configuration.log_forat = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.ignore_paths.reject! { |c| c == 'spec/**/*.pp' }
PuppetLint.configuration.ignore_paths << 'spec/fixtures/**/*.pp'

if Bundler.rubygems.find_name('metadata_json_lint').any?
  require 'metadata_json_lint'

  # PDK validate behaviors
  MetadataJsonLint.options.fail_on_warnings = true
  MetadataJsonLint.options.strict_license = true
  MetadataJsonLint.options.strict_puppet_version = true
  MetadataJsonLint.options.strict_dependencies = true
end

if Bundler.rubygems.find_name('dependency_checker').any?
  require 'dependency_checker'
  desc 'Run dependency-checker'
  task :metadata_deps do
    dpc = DependencyChecker::Runner.new
    dpc.resolve_from_files(['metadata.json'])
    dpc.run
    raise 'dependency checker failed' unless dpc.problems.zero?
  end
end

# output task execution
unless Rake.application.options.trace
  setup = ->(task, *_args) do
    puts "==> rake #{task.to_s}"
  end

  task :log_hooker do
    Rake::Task.tasks.reject { |t| t.to_s == 'log_hooker' }.each do |a_task|
      a_task.actions.prepend(setup)
    end
  end
  Rake.application.top_level_tasks.prepend(:log_hooker)
end
