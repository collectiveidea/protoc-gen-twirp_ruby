# frozen_string_literal: true

require_relative "../../core_ext/file/delete_extension"
require_relative "../../google/protobuf/compiler/plugin_pb"
require_relative "code_generator"

module Twirp
  module ProtocPlugin
    class Error < StandardError; end

    class << self
      # @param input [String] an encoded [Google::Protobuf::Compiler::CodeGeneratorRequest] message
      # @return [String] an encoded [Google::Protobuf::Compiler::CodeGeneratorResponse] message
      # @raise [Twirp::ProtocPlugin::Error] when the input is unreadable
      def process(input)
        request = Google::Protobuf::Compiler::CodeGeneratorRequest.decode(input)

        response = Google::Protobuf::Compiler::CodeGeneratorResponse.new
        response.supported_features = Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL

        request.proto_file.each do |proto_file|
          next unless request.file_to_generate.include?(proto_file.name)

          file = Google::Protobuf::Compiler::CodeGeneratorResponse::File.new
          file.name = twirp_output_filename(proto_file.name)
          file.content = CodeGenerator.new(proto_file, relative_ruby_protobuf(proto_file.name)).generate

          response.file << file
        end

        response.to_proto
      end

      # @param filename [String] the filename (with optional path) for the proto file,
      #   e.g. "some/example/hello.proto"
      # @return [String] the output filename for the proto file's generated twirp code,
      #   e.g. "some/example/hello_twirp.rb"
      def twirp_output_filename(filename)
        File.delete_extension(filename) + "_twirp.rb"
      end

      # @param filename [String] the filename (with optional path) for the proto file,
      #   e.g. "some/example/hello.proto"
      # @return [String] the file name of the generated ruby protobuf code from protoc,
      #   without any path information, minus the ".rb" extension, e.g. "hello_pb". We
      #   expect the generated twirp file to be in the same directory as the generated
      #   ruby output.
      def relative_ruby_protobuf(filename)
        File.basename(filename, File.extname(filename)) + "_pb" # no ".rb" extension
      end
    end
  end
end
