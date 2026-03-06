#!/usr/bin/env ruby
# frozen_string_literal: true

# Parses octocatalog-diff JSON output and prints a grouped, CI-friendly summary.
# Usage: octocatalog-diff --output-format json ... | ruby format_catalog_diff.rb [--ci]

require 'json'

COLLAPSE_THRESHOLD = 10
COLLAPSE_SHOW = 5

ci_mode = ARGV.include?('--ci')

raw_input = STDIN.read
begin
  data = JSON.parse(raw_input)
rescue JSON::ParserError => e
  $stderr.puts "Error: failed to parse octocatalog-diff output as JSON."
  $stderr.puts "Parse error: #{e.message}"
  $stderr.puts ""
  $stderr.puts "Raw output from octocatalog-diff:"
  $stderr.puts raw_input
  exit 1
end
diffs = data['diff'] || []

added   = diffs.select { |d| d['diff_type'] == '+' }
removed = diffs.select { |d| d['diff_type'] == '-' }
changed = diffs.select { |d| d['diff_type'] == '~' }

def group_by_type(items)
  items.group_by { |d| d['type'] }.sort_by(&:first)
end

# Try to extract hostname from Info resource
hostname = nil
diffs.each do |d|
  next unless d['type'] == 'Info'
  if d['title'] =~ /Host:\s+(\S+)/
    hostname = $1
    break
  end
end
hostname ||= 'unknown'

status = diffs.empty? ? 'NO DIFF' : 'DIFF FOUND'

# --- Plain text output ---

puts "=== Catalog Diff: #{hostname} ==="

if diffs.empty?
  puts "\u2713 No differences found"
else
  puts "Added: #{added.size}  |  Removed: #{removed.size}  |  Changed: #{changed.size}  |  Status: #{status}"
  puts

  if changed.any?
    puts "--- Changed (#{changed.size}) ---"
    group_by_type(changed).each do |type, items|
      puts "  #{type} (#{items.size})"
      items.sort_by { |d| d['title'] }.each do |d|
        title = d['title'].gsub("\n", ' ').strip
        puts "    ~ #{title}"
        attr_path = (d['structure'] || []).join(' > ')
        old_val = d['old_value']
        new_val = d['new_value']
        puts "        #{attr_path}: '#{old_val}' => '#{new_val}'"
      end
    end
    puts
  end

  if added.any?
    puts "--- Added (#{added.size}) ---"
    group_by_type(added).each do |type, items|
      sorted = items.sort_by { |d| d['title'] }
      puts "  #{type} (#{items.size})"
      display = items.size > COLLAPSE_THRESHOLD ? sorted.first(COLLAPSE_SHOW) : sorted
      display.each do |d|
        title = d['title'].gsub("\n", ' ').strip
        puts "    + #{title}"
      end
      if items.size > COLLAPSE_THRESHOLD
        puts "    ... and #{items.size - COLLAPSE_SHOW} more"
      end
    end
    puts
  end

  if removed.any?
    puts "--- Removed (#{removed.size}) ---"
    group_by_type(removed).each do |type, items|
      sorted = items.sort_by { |d| d['title'] }
      puts "  #{type} (#{items.size})"
      display = items.size > COLLAPSE_THRESHOLD ? sorted.first(COLLAPSE_SHOW) : sorted
      display.each do |d|
        title = d['title'].gsub("\n", ' ').strip
        puts "    - #{title}"
      end
      if items.size > COLLAPSE_THRESHOLD
        puts "    ... and #{items.size - COLLAPSE_SHOW} more"
      end
    end
  end
end

# --- Markdown step summary (CI mode) ---

if ci_mode
  md = []
  md << "### Catalog Diff: `#{hostname}`"
  md << ''

  if diffs.empty?
    md << ':white_check_mark: No differences found'
  else
    md << '| Added | Removed | Changed |'
    md << '|-------|---------|---------|'
    md << "| #{added.size} | #{removed.size} | #{changed.size} |"
    md << ''

    if changed.any?
      md << "#### Changed (#{changed.size})"
      md << '| Resource | Attribute | Old | New |'
      md << '|----------|-----------|-----|-----|'
      group_by_type(changed).each do |type, items|
        items.sort_by { |d| d['title'] }.each do |d|
          title = d['title'].gsub("\n", ' ').strip
          attr_path = (d['structure'] || []).join(' > ')
          old_val = d['old_value']
          new_val = d['new_value']
          md << "| #{type}[#{title}] | #{attr_path} | #{old_val} | #{new_val} |"
        end
      end
      md << ''
    end

    if added.any?
      md << "<details><summary>Added (#{added.size})</summary>"
      md << ''
      group_by_type(added).each do |type, items|
        titles = items.sort_by { |d| d['title'] }.map { |d| d['title'].gsub("\n", ' ').strip }
        if titles.size > COLLAPSE_THRESHOLD
          preview = titles.first(COLLAPSE_SHOW).join(', ')
          md << "- `#{type}` (#{titles.size}): #{preview}, ..."
        else
          titles.each { |t| md << "- `#{type}[#{t}]`" }
        end
      end
      md << ''
      md << '</details>'
      md << ''
    end

    if removed.any?
      md << "<details><summary>Removed (#{removed.size})</summary>"
      md << ''
      group_by_type(removed).each do |type, items|
        titles = items.sort_by { |d| d['title'] }.map { |d| d['title'].gsub("\n", ' ').strip }
        if titles.size > COLLAPSE_THRESHOLD
          preview = titles.first(COLLAPSE_SHOW).join(', ')
          md << "- `#{type}` (#{titles.size}): #{preview}, ..."
        else
          titles.each { |t| md << "- `#{type}[#{t}]`" }
        end
      end
      md << ''
      md << '</details>'
    end
  end

  if ENV['GITHUB_STEP_SUMMARY']
    File.open(ENV['GITHUB_STEP_SUMMARY'], 'a') do |f|
      f.puts md.join("\n")
    end
  else
    puts md.join("\n")
  end
end
