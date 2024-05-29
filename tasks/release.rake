# frozen_string_literal: true

require "bundler/gem_tasks"
require "date"
require "rake"
require "twirp/protoc_plugin/core_ext/string/to_anchor"

# See: https://github.com/rubygems/bundler-features/issues/81
# Remove the Bundler release task and override it with our own
Rake::Task["release"].clear

# Customize the release task originally defined at
# https://github.com/rubygems/rubygems/blob/v3.5.10/bundler/lib/bundler/gem_helper.rb#L67
#
#  * Do NOT push to RubyGems (remove need to specify `gem_push=no` by
#     removing `release:rubygem_push` dependency). The `release:source_control_push`
#     task triggers a RubyGems release using our GitHub Action as a trusted publisher.
#  * Create a GitHub release for the current version, with release notes
desc "Creates a release tag, pushes the tag to GitHub (which auto-releases to RubyGems), and creates a GitHub release."
task "release", [:remote] => %w[
  build
  release:guard_clean
  release:source_control_push
  release:create_github_release
]

desc "Gets the latest GitHub release version, e.g: v1.1.1"
task "release:latest_github_release" do
  # We could use `git` here to get the most recent version tag, like:
  #   `git tag --list --sort='-version:refname' 'v*' | head -n1`
  # but we go through the `gh` because we want the latest _GitHub_ release.
  $stdout << `gh release view --json tagName --jq '.tagName'`
end

desc "Creates a GitHub release for v#{Bundler::GemHelper.gemspec.version}"
task "release:create_github_release" do
  github_release = `bundle exec rake release:latest_github_release`.chomp
  version = Bundler::GemHelper.gemspec.version.to_s

  notes = <<~NOTES
    See [CHANGELOG.md](#{changelog_link(version)}) for release details.                                                                                                    
                                                                                                                    
    Full changes: #{compare_link(github_release, version)}
  NOTES

  `gh release create v#{version} --verify-tag --latest --notes "#{notes}"`
end

def repo_base_url
  "https://github.com/collectiveidea/protoc-gen-twirp_ruby"
end

def changelog_link(version)
  "#{repo_base_url}/blob/main/CHANGELOG.md##{changelog_heading(version).to_anchor}"
end

# @param version [String] the version, e.g. "1.2.0"
def changelog_heading(version)
  # Assume the heading in the CHANGELOG.md is always a consistent
  # format: "[1.1.1] - 2024-05-22"
  "[#{version}] - #{DateTime.now.strftime("%Y-%m-%d")}"
end

# @param previous_tag [String] the previous version tag, e.g. "v1.1.1"
# @param current_version [String] the current version, e.g. "1.2.0"
def compare_link(previous_tag, current_version)
  "#{repo_base_url}/compare/#{previous_tag}...v#{current_version}"
end
