# frozen_string_literal: true

require_relative "lib/twirp/protoc_plugin/version"

Gem::Specification.new do |spec|
  spec.name = "protoc-gen-twirp_ruby"
  spec.version = Twirp::ProtocPlugin::VERSION
  spec.authors = ["Darron Schall", "Daniel Morrison", "Chris Gaffney"]
  spec.email = "info@collectiveidea.com"

  spec.summary = "A protoc plugin for generating Twirp-Ruby clients and/or services"
  spec.description = "A protoc plugin that generates Twirp-Ruby services and clients. A pure Ruby alternative to the Go version that ships with Twirp-Ruby."
  spec.homepage = "https://github.com/collectiveidea/protoc-gen-twirp_ruby"

  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/collectiveidea/protoc-gen-twirp_ruby"
  spec.metadata["changelog_uri"] = "https://github.com/collectiveidea/protoc-gen-twirp_ruby/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/collectiveidea/protoc-gen-twirp_ruby/issues"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[
          .github/
          bin/
          example/
          proto/
          spec/
          tasks/
          .git
          .rspec
          .standard
          Gemfile
          Rakefile
        ])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "google-protobuf"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-file_fixtures"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "standard"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
