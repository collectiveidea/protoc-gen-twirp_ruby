# frozen_string_literal: true

RSpec.describe Twirp::ProtocPlugin do
  xit "generates expected output" do
    # TODO: service_gen_request_pb = <string containing code gen request protobuf message>
    response_pb = Twirp::ProtocPlugin.process(service_gen_request_pb)
    response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)
    expect(response.file.first.content).to eq <<~EOF
      require 'twirp'
      require_relative 'service_pb.rb'

      module Example
        module HelloWorld
          class HelloWorldService < ::Twirp::Service
            package 'example.hello_world'
            service 'HelloWorld'
            rpc :Hello, HelloRequest, HelloResponse, :ruby_method => :hello
          end

          class HelloWorldClient < ::Twirp::Client
            client_for HelloWorldService
          end
        end
      end
    EOF
  end
end
