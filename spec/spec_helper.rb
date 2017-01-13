require 'simplecov'

SimpleCov.profiles.define 'social_media' do
  add_filter '/spec/'
end

SimpleCov.start 'social_media'

require 'rspec'
require 'rspec/its'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.debug_logger = File.open('log/vcr.log', 'w')
  config.ignore_request do |request|
    URI(request.uri).path == "/shutdown"
  end
end

require_relative '../lib/social_media'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
