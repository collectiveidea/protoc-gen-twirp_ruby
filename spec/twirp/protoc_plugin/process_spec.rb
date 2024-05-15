# frozen_string_literal: true

RSpec.describe Twirp::ProtocPlugin do
  describe "#process" do
    context "when passing an invalid parameter" do
      # Generate code gen request fixture:
      #   `./spec/support/create_fixture -b -p unrecognized -f service_code_gen_request_unrecognized_param_pb.bin ./spec/fixtures/service.proto`
      let(:request_pb) { fixture("service_code_gen_request_unrecognized_param_pb.bin").read }

      it "raises an argument error" do
        expect {
          Twirp::ProtocPlugin.process(request_pb)
        }.to raise_error(ArgumentError, "Invalid option: unrecognized")
      end
    end

    context "when passing an invalid value for the skip-empty flag" do
      # Generate code gen request fixture:
      #   `./spec/support/create_fixture -b -p skip-empty=true -f service_code_gen_request_invalid_skip_empty_value_param_pb.bin ./spec/fixtures/service.proto`
      let(:request_pb) { fixture("service_code_gen_request_invalid_skip_empty_value_param_pb.bin").read }

      it "raises an argument error" do
        expect {
          Twirp::ProtocPlugin.process(request_pb)
        }.to raise_error(ArgumentError, "Unexpected value passed to skip-empty flag: true")
      end
    end

    context "when using the example from the original go plugin" do
      # The `service.proto` fixture is from:
      #   https://github.com/arthurnn/twirp-ruby/blob/v1.11.0/example/hello_world/service.proto
      #
      # Generate code gen request fixture:
      #   `./spec/support/create_fixture -b -f service_code_gen_request_pb.bin ./spec/fixtures/service.proto`
      let(:service_code_gen_request_pb) { fixture("service_code_gen_request_pb.bin").read }

      it "generates expected output" do
        response_pb = Twirp::ProtocPlugin.process(service_code_gen_request_pb)
        response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)

        expect(response.supported_features).to eq(Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL)
        expect(response.file.size).to eq(1)
        expect(response.file.first.name).to eq("spec/fixtures/service_twirp.rb")
        # Match the general output of the 1.11.0 go plugin when ran against the same service.proto.
        # See: https://github.com/arthurnn/twirp-ruby/blob/v1.11.0/example/hello_world/service_twirp.rb
        expect(response.file.first.content).to eq <<~EOF
          # frozen_string_literal: true
          
          # Generated by the protoc-gen-twirp_ruby gem v#{Twirp::ProtocPlugin::VERSION}. DO NOT EDIT!
          # source: spec/fixtures/service.proto
    
          require "twirp"
          require_relative "service_pb"
    
          module Example
            module HelloWorld
              class HelloWorldService < ::Twirp::Service
                package "example.hello_world"
                service "HelloWorld"
                rpc :Hello, HelloRequest, HelloResponse, ruby_method: :hello
              end
    
              class HelloWorldClient < ::Twirp::Client
                client_for HelloWorldService
              end
            end
          end
        EOF
      end
    end

    context "when using a well-named service" do
      # The `well_named_service.proto` fixture is copied from `service.proto` and updated
      # to name the service properly according to convention.
      #
      # Generate code gen request fixture:
      #   `./spec/support/create_fixture -b -f well_named_service_code_gen_request_pb.bin ./spec/fixtures/well_named_service.proto`
      let(:well_named_service_code_gen_request_pb) { fixture("well_named_service_code_gen_request_pb.bin").read }

      it "generates expected output" do
        response_pb = Twirp::ProtocPlugin.process(well_named_service_code_gen_request_pb)
        response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)

        expect(response.supported_features).to eq(Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL)
        expect(response.file.size).to eq(1)
        expect(response.file.first.name).to eq("spec/fixtures/well_named_service_twirp.rb")
        expect(response.file.first.content).to eq <<~EOF
          # frozen_string_literal: true
          
          # Generated by the protoc-gen-twirp_ruby gem v#{Twirp::ProtocPlugin::VERSION}. DO NOT EDIT!
          # source: spec/fixtures/well_named_service.proto
    
          require "twirp"
          require_relative "well_named_service_pb"
    
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
        EOF
      end
    end

    context "when using a file that imports types from another file" do
      context "when omitting the `skip-empty` option" do
        # Generate code gen request fixture:
        #   `./spec/support/create_fixture -b -f example_code_gen_request_pb.bin -o ./spec/fixtures/import_type_retention -I ./spec/fixtures/import_type_retention example.proto package/actions/asks.proto`
        let(:example_code_gen_request_pb) { fixture("import_type_retention/example_code_gen_request_pb.bin").read }

        it "generates expected output" do
          response_pb = Twirp::ProtocPlugin.process(example_code_gen_request_pb)
          response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)

          expect(response.supported_features).to eq(Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL)
          expect(response.file.size).to eq(2)

          first_file = response.file[0]
          expect(first_file.name).to eq("package/actions/asks_twirp.rb")
          expect(first_file.content).to eq <<~EOF
            # frozen_string_literal: true

            # Generated by the protoc-gen-twirp_ruby gem v#{Twirp::ProtocPlugin::VERSION}. DO NOT EDIT!
            # source: package/actions/asks.proto

            require "twirp"
            require_relative "asks_pb"

            module Package
              module Actions
                module Asks
                end
              end
            end
          EOF

          second_file = response.file[1]
          expect(second_file.name).to eq("example_twirp.rb")
          expect(second_file.content).to eq <<~EOF
            # frozen_string_literal: true

            # Generated by the protoc-gen-twirp_ruby gem v#{Twirp::ProtocPlugin::VERSION}. DO NOT EDIT!
            # source: example.proto

            require "twirp"
            require_relative "example_pb"

            module Package
              module Rpc
                module Asks
                  class AskService < ::Twirp::Service
                    package "package.rpc.asks"
                    service "Ask"
                    rpc :GetAskSnapshot, ::Package::Actions::Asks::RequestAskSnapshot, ::Package::Actions::Asks::AskSnapshot, ruby_method: :get_ask_snapshot
                  end

                  class AskClient < ::Twirp::Client
                    client_for AskService
                  end
                end
              end
            end
          EOF
        end
      end

      context "when specifying the `skip-empty` option`" do
        # Generate code gen request fixture:
        #   `./spec/support/create_fixture -b -f example_code_gen_request_skip_empty_pb.bin -p skip-empty -o ./spec/fixtures/import_type_retention -I ./spec/fixtures/import_type_retention example.proto package/actions/asks.proto`
        let(:example_code_gen_request_skip_empty_pb) { fixture("import_type_retention/example_code_gen_request_skip_empty_pb.bin").read }

        it "generates expected output" do
          response_pb = Twirp::ProtocPlugin.process(example_code_gen_request_skip_empty_pb)
          response = Google::Protobuf::Compiler::CodeGeneratorResponse.decode(response_pb)

          expect(response.supported_features).to eq(Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL)
          expect(response.file.size).to eq(1)

          first_file = response.file[0]
          expect(first_file.name).to eq("example_twirp.rb")
          expect(first_file.content).to eq <<~EOF
            # frozen_string_literal: true

            # Generated by the protoc-gen-twirp_ruby gem v#{Twirp::ProtocPlugin::VERSION}. DO NOT EDIT!
            # source: example.proto

            require "twirp"
            require_relative "example_pb"

            module Package
              module Rpc
                module Asks
                  class AskService < ::Twirp::Service
                    package "package.rpc.asks"
                    service "Ask"
                    rpc :GetAskSnapshot, ::Package::Actions::Asks::RequestAskSnapshot, ::Package::Actions::Asks::AskSnapshot, ruby_method: :get_ask_snapshot
                  end

                  class AskClient < ::Twirp::Client
                    client_for AskService
                  end
                end
              end
            end
          EOF
        end
      end
    end
  end
end
