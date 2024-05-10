# frozen_string_literal: true

# Generated by the protoc-gen-twirp_ruby gem v0.1.0. DO NOT EDIT!
# source: example/hello_world.proto

require "twirp"
require_relative "hello_world_pb"

module Example
  module HelloWorld
    class HelloWorldServiceService < ::Twirp::Service
      package "example.hello_world"
      service "HelloWorldService"
      rpc :Hello, HelloRequest, HelloResponse, ruby_method: :hello
    end

    class HelloWorldServiceClient < ::Twirp::Client
      client_for HelloWorldServiceService
    end
  end
end