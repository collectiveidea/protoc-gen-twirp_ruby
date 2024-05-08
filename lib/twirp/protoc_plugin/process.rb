# frozen_string_literal: true

require_relative "../../google/protobuf/compiler/plugin_pb"
require "stringio"

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

        request.proto_file.each do |proto_file|
          output = StringIO.new
          output << "# from file: #{proto_file.name}\n"
          output << "# package: #{proto_file.package}\n"
          output << "require \"google/protobuf\"\n"

          # TODO: Loop over services in file and generate properly

          file = Google::Protobuf::Compiler::CodeGeneratorResponse::File.new
          file.name = "#{proto_file.name.sub(".proto", "")}_service.rb"
          file.content = output.string
          response.file << file
        end

        response.to_proto
      end
    end
  end
end
