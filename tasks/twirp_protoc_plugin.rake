# frozen_string_literal: true

require "rake"

desc "Re-runs code generation for the example using local plugin code."
task :example do
  %x(protoc --plugin=protoc-gen-twirp_ruby=./exe/protoc-gen-twirp_ruby \
      --ruby_out=. \
      --twirp_ruby_out=. \
      ./example/hello_world.proto
  )
end
