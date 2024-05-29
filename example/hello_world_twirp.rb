# frozen_string_literal: true

# Generated by the protoc-gen-twirp_ruby gem v1.2.0. DO NOT EDIT!
# source: example/hello_world.proto

require "twirp"
require_relative "hello_world_pb"

module Example
  module HelloWorld
    class HelloWorldService < ::Twirp::Service
      package "example.hello_world"
      service "HelloWorldService"
      rpc :Hello, HelloRequest, HelloResponse, ruby_method: :hello
    end

    class HelloWorldClient < ::Twirp::Client
      client_for HelloWorldService
    end
  end
end
