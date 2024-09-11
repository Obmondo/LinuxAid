#
# sentry_dsn.rb - Set facts for the sentry dsn urls for apps install on the host
# 
require 'facter'
require 'net/http'
require 'openssl'
require 'resolv'
require 'timeout'

# Lookup the Sentry DSN url from cache file or right from Sentry itself
def app_lookup (app_name, sentry_url)
  cache_file = "/var/cache/sentry_dsn/#{app_name}"
  if File.exists?(cache_file)
    Facter.add(:"#{app_name}_sentry_dsn".to_sym) do
      setcode do
        File.read(cache_file)
      end
    end
  else
    begin
      uri = URI(sentry_url + app_name)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code == '200' then
        Facter.add(:"#{app_name}_sentry_dsn".to_sym) do
          setcode do
            response.body
          end
        end
        File.open(cache_file, 'w') { |file| file.write(response.body) }
      end
    rescue
      # It didn't work. Oh well
      Facter.debug("Error setting sentry_dsn for #{app_name}")
    end
  end
end

# See if the sentry hostname resolves (so this works in Vagrant)
def sentry_resolve (sentry_host)
  begin
    Resolv::getaddress(sentry_host)
    return true
  rescue
    return false
  end
end

#
# Main 
#
if not File.directory("/var/cache/sentry_dsn/") then
  Dir.mkdir("/var/cache/sentry_dsn/")
end
app_env = Facter.value(:app_env)

#
#
# This part is where you'd customize to your environment
#
#
sentry_host = case app_env 
              when 'production' then 'sentry.example.com'
              when 'testing' then 'sentry.testing.example.com'
              when 'development' then 'sentry.dev'
              end
sentry_url = "https://#{sentry_host}/dsn/"
  
if sentry_resolve(sentry_host) 
  applications = whatever.method.to.get.a.list.of.apps.installed.on.this.server()
  applications.each do |app|
    begin
      expire_time=10 #seconds
      Timeout.timeout(expire_time) do
        app_lookup(app, sentry_url)
      end
    rescue Timeout::Error
      # Timeout expired, tell debug and stop future app_lookups
      Facter.debug("Timeout in app_lookup() for '#{app}'. Skipping remaining apps.")
      break
    end
  end
end
