require 'bundler/setup'
require 'rsteamshot'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.order = :random

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :be_a_screenshot do
  match do |screenshot|
    screenshot.class == Rsteamshot::Screenshot &&
      !screenshot.details_url.nil? &&
      !screenshot.full_size_url.nil? &&
      !screenshot.medium_url.nil? &&
      !screenshot.user_name.nil? &&
      !screenshot.like_count.nil? &&
      !screenshot.comment_count.nil? &&
      !screenshot.user_url.nil?
  end
  failure_message do |screenshot|
    if screenshot.class == Rsteamshot::Screenshot
      if screenshot.details_url.nil?
        "details_url should not be nil"
      elsif screenshot.full_size_url.nil?
        "full_size_url should not be nil"
      elsif screenshot.medium_url.nil?
        "medium_url should not be nil"
      elsif screenshot.user_name.nil?
        "user_name should not be nil"
      elsif screenshot.like_count.nil?
        "like_count should not be nil"
      elsif screenshot.comment_count.nil?
        "comment_count should not be nil"
      elsif screenshot.user_url.nil?
        "user_url should not be nil"
      end
    else
      "got #{screenshot.class.name}, expected Rsteamshot::Screenshot"
    end
  end
end
