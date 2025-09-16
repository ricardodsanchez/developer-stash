#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'date'
require 'cgi'

DATA_PATH = File.expand_path('../_data/resources.yml', __dir__)
OUTPUT_PATH = File.expand_path('../README.md', __dir__)

unless File.exist?(DATA_PATH)
  warn "Missing data file: #{DATA_PATH}"
  exit 1
end

data = YAML.load_file(DATA_PATH)
legend = data['status_legend'] || {}
raw_last_vetted = data['last_vetted'] || Date.today.to_s
last_vetted = raw_last_vetted.to_s
categories = data['categories'] || []
total_resources = categories.map { |c| (c['resources'] || []).size }.sum
generated_at_full = Time.now.utc # keep full time for potential future use
# Use date only to reduce badge volatility / caching issues; still deterministic per day
generated_date = generated_at_full.strftime('%Y-%m-%d')

# Helper to build markdown table rows with consistent pipes
class Table
  def initialize(headers)
    @headers = headers
    @rows = []
  end
  def add_row(*cells)
    @rows << cells
  end
  def to_md
    header_line = '| ' + @headers.join(' | ') + ' |'
    sep_line = '| ' + @headers.map { '---' }.join(' | ') + ' |'
    body = @rows.map { |r| '| ' + r.join(' | ') + ' |' }.join("\n")
    [header_line, sep_line, body].join("\n")
  end
end

def linkify(name, url, tracking: false)
  clean = url.to_s.strip
  clean += '?developerstash' if tracking && !clean.include?('?')
  clean += '&developerstash' if tracking && clean.include?('?') && !clean.include?('developerstash')
  "[#{name}](#{clean})"
end

readme = []
readme << '# Developer Stash'
readme << ''
readme << "Curated resources and tools for developers. Generated from structured data."
readme << ''
# Shields.io badge segments need proper URL encoding; use CGI.escape
def badge(subject, status, color, style: 'flat-square')
  label = CGI.escape(subject.to_s)
  message = CGI.escape(status.to_s)
  "![#{subject.split('_').map(&:capitalize).join(' ')}](https://img.shields.io/static/v1?label=#{label}&message=#{message}&color=#{color}&style=#{style})"
end

badge_last_generated = badge('last_generated', generated_date, 'blue')
badge_last_vetted = badge('last_vetted', last_vetted, 'green')
badge_total = badge('resources', total_resources, 'purple')
readme << [badge_last_generated, badge_last_vetted, badge_total].join(' ')
readme << ''
readme << '## How to use it'
readme << ''
readme << 'Browse categories below. Each resource includes a status indicator to help you assess current relevance.'
readme << ''
readme << 'Status legend:'
readme << ''
legend_table = Table.new(%w[Status Meaning])
legend.each do |k, v|
  legend_table.add_row(k, v)
end
readme << legend_table.to_md
readme << ''
readme << '## Index'
readme << ''
categories.each do |cat|
  readme << "- [#{cat['title']}](##{cat['title'].downcase.gsub(/[^a-z0-9]+/, '-')})"
end
readme << ''

categories.each do |cat|
  readme << "### #{cat['title']}"
  readme << ''
  readme << cat['description'] if cat['description']
  readme << ''
  table = Table.new(['Name', 'Status', 'Description', 'Website'])
  (cat['resources'] || []).each do |res|
    name = res['name']
    url = res['url']
    status = res['status'] || 'unknown'
    desc = res['description'] || ''
    table.add_row(linkify(name, url, tracking: false), status, desc.gsub('|', '\\|'), linkify('Visit', url, tracking: false))
  end
  readme << table.to_md
  readme << ''
end

readme << '## Getting involved'
readme << ''
readme << 'Contributions welcome. Update `_data/resources.yml` and run `scripts/generate_readme.rb`.'
readme << ''
readme << '## License'
readme << ''
readme << 'Everything in this repo is MIT License unless otherwise specified.'
readme << ''
readme << 'MIT © Ricardo Sanchez'
readme << ''

File.write(OUTPUT_PATH, readme.join("\n"))
puts "README generated successfully (#{OUTPUT_PATH})."
