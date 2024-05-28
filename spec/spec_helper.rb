# frozen_string_literal: true

if %w[t true yes y 1].include?(ENV["COVERAGE"])
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch
  end
end

require "rspec/file_fixtures"
require "twirp/protoc_plugin"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
