# frozen_string_literal: true

require "net/http"
require "json"
require "time"

# @summary
#
#   Resolve the Splunk Universal Forwarder version+build to install. Given
#   both version and build, returns them as-is (a pin). Given neither, looks
#   up the latest release by scraping Splunk's own download page (there is
#   no stable "latest" download URL or public API for this) - result is
#   cached on disk (compiler-side) for CACHE_TTL_SECONDS so we don't hit
#   Splunk's site on every catalog compile.
#
#   On any lookup failure (network, parse, Splunk page layout change) this
#   falls back to a stale cache if one exists, or a hardcoded last-known-good
#   version if not - it never raises, since that would break catalog
#   compilation for every node using this class.
#
# Real module keyword (not the create_function do...end block below) so these get proper
# lexical scoping - constants assigned directly inside create_function's block leak onto
# top-level Object in the puppetserver JRuby, since Class.new-style blocks don't nest in
# Module.nesting the way `module`/`class` do.
module SplunkForwarderLatestVersion
  DOWNLOAD_PAGE = "https://www.splunk.com/en_us/download/universal-forwarder.html"
  CACHE_TTL_SECONDS = 6 * 60 * 60 # 6 hours
  # Used only if there is no cache at all yet AND the live fetch also fails.
  FALLBACK = { "version" => "10.4.2", "build" => "33c3bf42cd73" }.freeze

  # Puppet[:vardir] is writable by the compiling process by construction, unlike
  # /opt/obmondo/cache - which nothing in this repo creates or manages on the
  # puppetserver (only on agent nodes, via common::init's $__opt_dir), so
  # write_cache would silently fail there and force a live HTTP fetch on every
  # catalog compile. Puppet[:vardir] is a runtime setting, not a static
  # literal, so this is a method rather than a constant.
  def self.cache_path
    File.join(Puppet[:vardir], "splunk_forwarder_latest_version.json")
  end
end

Puppet::Functions.create_function(:splunk_forwarder_latest_version) do
  dispatch :latest do
    required_param 'Optional[String[1]]', :version
    required_param 'Optional[String[1]]', :build
    return_type 'Struct[{version => String[1], build => String[1]}]'
  end

  def latest(version, build)
    return { "version" => version, "build" => build } if version && build

    cached = read_cache
    return cached.slice("version", "build") if cached && !stale?(cached)

    begin
      fetched = fetch_latest
      write_cache(fetched)
      fetched
    rescue StandardError => e
      Puppet.warning("splunk_forwarder_latest_version: failed to fetch latest release (#{e.message}), " \
                      "falling back to #{cached ? 'stale cache' : 'hardcoded default'}")
      cached ? cached.slice("version", "build") : SplunkForwarderLatestVersion::FALLBACK
    end
  end

  private

  def fetch_latest
    uri = URI(SplunkForwarderLatestVersion::DOWNLOAD_PAGE)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.get(uri)
    end
    raise "unexpected response #{response.code}" unless response.code.to_i == 200

    # Match the linux x86_64 rpm link, e.g.
    # .../releases/10.4.2/linux/splunkforwarder-10.4.2-33c3bf42cd73.x86_64.rpm
    match = response.body.match(%r{splunkforwarder-(?<version>\d+(?:\.\d+)*)-(?<build>[0-9a-f]{12})\.x86_64\.rpm})
    raise "could not find a version/build match on the download page" unless match

    { "version" => match[:version], "build" => match[:build] }
  end

  def read_cache
    return nil unless File.exist?(SplunkForwarderLatestVersion.cache_path)

    JSON.parse(File.read(SplunkForwarderLatestVersion.cache_path))
  rescue StandardError
    nil
  end

  def stale?(cached)
    (Time.now - Time.parse(cached["fetched_at"])) > SplunkForwarderLatestVersion::CACHE_TTL_SECONDS
  rescue StandardError
    true
  end

  def write_cache(data)
    # No mkdir_p needed - Puppet[:vardir] always exists already. Unique per-writer temp filename,
    # since puppetserver compiles many catalogs concurrently in one JVM (Process.pid alone
    # wouldn't differentiate threads in the same process) - a shared fixed temp name would let
    # concurrent writers splice/truncate each other's write before either renames it into place.
    tmp_path = "#{SplunkForwarderLatestVersion.cache_path}.#{Process.pid}.#{Thread.current.object_id}.tmp"
    File.write(tmp_path, data.merge("fetched_at" => Time.now.utc.iso8601).to_json)
    File.rename(tmp_path, SplunkForwarderLatestVersion.cache_path)
  rescue StandardError => e
    Puppet.warning("splunk_forwarder_latest_version: failed to write cache (#{e.message})")
  ensure
    File.unlink(tmp_path) if tmp_path && File.exist?(tmp_path)
  end
end
