# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

# Load development-only rake tasks. There are in `tasks/` and not
# `lib/tasks/` because we don't want to ship them with the gem.
Rake.add_rakelib "tasks"

task default: %i[spec standard]
