module TestDependencies
  def with_test_dependencies(test_manifest)
    setup_manifest + test_manifest
  end

  def setup_manifest
    <<-EOS
      file { '/var/www':
        ensure => directory,
      }

      package { 'curl':
        ensure => installed,
      }

      package { 'php5-cli':
        ensure => installed,
      }
    EOS
  end
end
