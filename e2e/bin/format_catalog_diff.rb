#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'optparse'
require 'tempfile'

# Formats octocatalog-diff JSON output into human-readable text and Markdown.
class CatalogDiffFormatter
  COLLAPSE_THRESHOLD = 10
  COLLAPSE_SHOW = 5
  SEPARATOR = '*' * 80

  def initialize(raw_input, options = {})
    @raw_input = raw_input
    @options = options
    @data = parse_input
    @diffs = @data['diff'] || []
  end

  def run
    print_plain_text
    print_markdown if @options[:ci]
  end

  private

  def parse_input
    return {} if @raw_input.nil? || @raw_input.strip.empty?

    JSON.parse(@raw_input)
  rescue JSON::ParserError => e
    warn "Error: failed to parse octocatalog-diff output as JSON."
    warn "Parse error: #{e.message}"
    warn "\nRaw output from octocatalog-diff:\n#{@raw_input}"
    exit 1
  end

  def hostname
    @hostname ||= @options[:hostname] ||
                  @data.dig('info', 'to_hostname') ||
                  @data.dig('info', 'from_hostname') ||
                  'unknown'
  end

  def colorize?
    @options[:color] && $stdout.tty?
  end

  def c(code, text)
    colorize? ? "\e[#{code}m#{text}\e[0m" : text.to_s
  end

  def green(text) = c(32, text)
  def red(text)   = c(31, text)

  def resource_name(d)
    "#{d['type']}[#{d['title'].gsub("\n", ' ').strip}]"
  end

  def group_by_type(items)
    items.group_by { |d| d['type'] }.sort_by(&:first)
  end

  def diff_summary
    @diff_summary ||= {
      added: @diffs.select { |d| d['diff_type'] == '+' },
      removed: @diffs.select { |d| d['diff_type'] == '-' },
      changed: @diffs.select { |d| d['diff_type'] == '~' }
    }
  end

  def print_plain_text
    if @diffs.empty?
      puts green("\u2713 No differences found for #{hostname}")
      return
    end

    entries = plain_text_entries.sort_by { |e| e[:resource] }
    entries.each do |entry|
      send("print_#{entry[:action]}", entry)
      puts SEPARATOR
    end
  end

  def plain_text_entries
    entries = []
    diff_summary[:added].each   { |d| entries << { resource: resource_name(d), action: :added,   data: d } }
    diff_summary[:removed].each { |d| entries << { resource: resource_name(d), action: :removed, data: d } }
    diff_summary[:changed].group_by { |d| resource_name(d) }.each do |res, ds|
      entries << { resource: res, action: :changed, diffs: ds }
    end
    entries
  end

  def print_added(entry)   = print_added_or_removed(entry, added: true)
  def print_removed(entry) = print_added_or_removed(entry, added: false)

  def print_added_or_removed(entry, added:)
    prefix    = added ? '+' : '-'
    value_key = added ? 'new_value' : 'old_value'
    color     = ->(text) { added ? green(text) : red(text) }

    puts "  #{color.call(prefix)} #{color.call("#{entry[:resource]} =>")}"

    params = entry[:data].dig(value_key, 'parameters')
    return unless params.is_a?(Hash) && params.any?

    puts "   #{color.call('parameters =>')}"
    params.each { |k, v| puts "   #{color.call("     #{k} => '#{v}',")}" }
  end

  def print_changed(entry)
    puts "  #{entry[:resource]} =>"
    puts "   parameters =>"
    entry[:diffs].sort_by { |d| (d['structure'] || []).join(' > ') }.each do |d|
      attr = (d['structure'] || []).last || '?'
      old_v = d['old_value'].to_s
      new_v = d['new_value'].to_s
      if old_v.include?("\n") || new_v.include?("\n")
        puts "    #{attr} =>"
        unified_diff(old_v, new_v).each_line do |line|
          puts "      #{colorize_diff_line(line.chomp)}"
        end
      else
        puts "    #{red("-  #{attr} => '#{old_v}'")}"
        puts "    #{green("+  #{attr} => '#{new_v}'")}"
      end
    end
  end

  # Returns a unified diff (without the leading file headers) of two strings.
  def unified_diff(old_str, new_str)
    Tempfile.create('ocd-old') do |o|
      Tempfile.create('ocd-new') do |n|
        o.write(old_str); o.flush
        n.write(new_str); n.flush
        `diff -u --label old --label new #{o.path} #{n.path}`
      end
    end
  end

  def colorize_diff_line(line)
    case line
    when /\A\+/ then green(line)
    when /\A-/  then red(line)
    else line
    end
  end

  def print_markdown
    md = ["### Catalog Diff: `#{hostname}`", '']
    if @diffs.empty?
      md << ':white_check_mark: No differences found'
    else
      md.concat(markdown_summary_table)
      md.concat(markdown_changed_section) if diff_summary[:changed].any?
      md.concat(markdown_details_section('Added',   diff_summary[:added]))
      md.concat(markdown_details_section('Removed', diff_summary[:removed]))
    end
    emit_markdown(md.join("\n"))
  end

  def markdown_summary_table
    s = diff_summary
    [
      '| Added | Removed | Changed |',
      '|-------|---------|---------|',
      "| #{s[:added].size} | #{s[:removed].size} | #{s[:changed].size} |",
      ''
    ]
  end

  def markdown_changed_section
    changed = diff_summary[:changed]
    lines = [
      "#### Changed (#{changed.size})",
      '| Resource | Attribute | Old | New |',
      '|----------|-----------|-----|-----|'
    ]
    group_by_type(changed).each do |_type, items|
      items.sort_by { |d| d['title'] }.each do |d|
        attr_path = (d['structure'] || []).join(' > ')
        lines << "| #{resource_name(d)} | #{attr_path} | #{d['old_value']} | #{d['new_value']} |"
      end
    end
    lines << ''
    lines
  end

  def markdown_details_section(label, items)
    return [] if items.empty?

    lines = ["<details><summary>#{label} (#{items.size})</summary>", '']
    group_by_type(items).each do |type, group|
      resources = group.sort_by { |d| d['title'] }.map { |d| resource_name(d) }
      if resources.size > COLLAPSE_THRESHOLD
        lines << "- `#{type}` (#{resources.size}): #{resources.first(COLLAPSE_SHOW).join(', ')}, ..."
      else
        resources.each { |r| lines << "- `#{r}`" }
      end
    end
    lines << ''
    lines << '</details>'
    lines << ''
    lines
  end

  def emit_markdown(output)
    if ENV['GITHUB_STEP_SUMMARY']
      File.open(ENV['GITHUB_STEP_SUMMARY'], 'a') { |f| f.puts output }
    else
      puts "\n--- Markdown Summary ---\n#{output}"
    end
  end
end

# --- Main ---

options = {
  color: true,
  ci: false,
  hostname: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: format_catalog_diff.rb [options]"

  opts.on("--ci", "Enable CI mode (Markdown output)") { options[:ci] = true }
  opts.on("--no-color", "Disable colorized output") { options[:color] = false }
  opts.on("--hostname HOSTNAME", "Explicit hostname for report") { |h| options[:hostname] = h }
end.parse!

formatter = CatalogDiffFormatter.new($stdin.read, options)
formatter.run
