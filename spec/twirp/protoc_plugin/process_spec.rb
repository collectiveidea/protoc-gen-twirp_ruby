# frozen_string_literal: true

RSpec.describe Twirp::ProtocPlugin do
  # Generate fixture:
  #   `./spec/support/create_fixture -b -f service_code_gen_request_pb.bin ./spec/fixtures/service.proto`
  let(:service_code_gen_request_pb) { fixture("service_code_gen_request_pb.bin").read }

  xit "generates expected output" do
    response_pb = Twirp::ProtocPlugin.process(service_code_gen_request_pb)
    response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)
    # Match the output of the 1.10.0 go plugin when ran against the same service.proto.
    # See: https://github.com/arthurnn/twirp-ruby/blob/1a653da2aec51723a403e6741dbebfefd38b0730/example/hello_world/service_twirp.rb
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
