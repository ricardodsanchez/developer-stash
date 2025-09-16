#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'uri'

DATA_PATH = File.expand_path('../_data/resources.yml', __dir__)

unless File.exist?(DATA_PATH)
  warn "Missing data file: #{DATA_PATH}"
  exit 1
end

data = YAML.load_file(DATA_PATH)
allowed_statuses = %w[core niche legacy deprecated emerging declining]
errors = []

last_vetted = data['last_vetted']
errors << 'Missing top-level last_vetted (ISO date expected)' unless last_vetted.is_a?(String) && /\A\d{4}-\d{2}-\d{2}\z/.match?(last_vetted)

categories = data['categories']
errors << 'Missing categories array' unless categories.is_a?(Array)

all_names = {}

if categories.is_a?(Array)
  categories.each do |cat|
    cid = cat['id'] || '(no id)'
    title = cat['title'] || '(no title)'
    unless cat['resources'].is_a?(Array)
      errors << "Category #{cid} (#{title}) missing resources array"
      next
    end

    cat['resources'].each_with_index do |res, idx|
      path = "#{cid}[#{idx}]"
      name = res['name']
      url = res['url']
      status = res['status']
      desc = res['description']

      errors << "#{path}: missing name" unless name.is_a?(String) && !name.strip.empty?
      errors << "#{path}: missing url" unless url.is_a?(String) && !url.strip.empty?
      if url.is_a?(String)
        begin
          uri = URI.parse(url)
          unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
            errors << "#{path}: url is not HTTP/HTTPS (#{url})"
          end
        rescue StandardError
          errors << "#{path}: invalid url format (#{url})"
        end
      end
      errors << "#{path}: missing description" unless desc.is_a?(String) && !desc.strip.empty?
      if status.nil? || !allowed_statuses.include?(status)
        errors << "#{path}: invalid status '#{status}' (allowed: #{allowed_statuses.join(', ')})"
      end

      if name
        norm = name.downcase.strip
        if all_names.key?(norm)
          errors << "Duplicate resource name '#{name}' also seen in #{all_names[norm]}"
        else
          all_names[norm] = path
        end
      end
    end
  end
end

if errors.empty?
  puts 'Validation passed: no issues found.'
  exit 0
else
  puts "Validation failed with #{errors.size} issue(s):"
  errors.each { |e| puts " - #{e}" }
  exit 1
end
