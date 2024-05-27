# frozen_string_literal: true

require "rake"

desc "Gets the latest GitHub release version, e.g: v1.1.1"
task "release:latest_github_release" do
  # We could use `git` here to get the most recent version tag, like:
  #   `git tag --list --sort='-version:refname' 'v*' | head -n1`
  # but we go through the `gh` because we want the latest _GitHub_ release.
  $stdout << `gh release view --json tagName --jq '.tagName'`
end
