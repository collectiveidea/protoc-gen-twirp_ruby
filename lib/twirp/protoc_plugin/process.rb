# frozen_string_literal: true

require_relative "../../core_ext/file/delete_extension"
require_relative "../../google/protobuf/compiler/plugin_pb"
require_relative "descriptor_ext/file_descriptor_proto_ext"
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

        request.proto_file.each do |proto_file| # proto_file: <Google::Protobuf::FileDescriptorProto>
          next unless request.file_to_generate.include?(proto_file.name)

          file = Google::Protobuf::Compiler::CodeGeneratorResponse::File.new
          file.name = proto_file.twirp_output_filename
          file.content = CodeGenerator.new(proto_file, proto_file.relative_ruby_protobuf_name).generate

          response.file << file
        end

        response.to_proto
      end
    end
  end
end
