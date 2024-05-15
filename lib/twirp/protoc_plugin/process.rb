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
      # @raise [ArgumentError] when a required parameter is missing, a parameter value is invalid, or
      #   an unrecognized parameter is present on the command line
      def process(input)
        request = Google::Protobuf::Compiler::CodeGeneratorRequest.decode(input)

        options = extract_params(request.parameter)

        response = Google::Protobuf::Compiler::CodeGeneratorResponse.new
        response.supported_features = Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL

        request.proto_file.each do |proto_file| # proto_file: <Google::Protobuf::FileDescriptorProto>
          next unless request.file_to_generate.include?(proto_file.name)

          file = Google::Protobuf::Compiler::CodeGeneratorResponse::File.new
          file.name = proto_file.twirp_output_filename
          file.content = CodeGenerator.new(proto_file, proto_file.relative_ruby_protobuf_name, options).generate

          response.file << file
        end

        response.to_proto
      end

      private

      # @param params [String] the parameters from protoc command line in comma-separated stringified
      #   array format, e.g. "some-flag,key1=value1".
      #
      #   The only valid parameter is currently the optional "skip-empty" flag.
      # @return [Hash{Symbol => Boolean}]
      #   * :skip_empty [Boolean] indicating whether generation should skip creating a twirp file
      #       for proto files that contain no services. Default false.
      # @raise [ArgumentError] when a required parameter is missing, a parameter value is invalid, or
      #   an unrecognized parameter is present on the command line
      def extract_params(params)
        opts = {
          skip_empty: false
        }

        # Process the options passed to the plugin from `protoc`.
        params.split(",").each do |param|
          # In the event value contains an =, we want to leave that intact.
          # Limit the split to just separate the key out.
          key, value = param.split("=", 2)
          if key == "skip-empty"
            unless value.nil? || value.empty?
              raise ArgumentError, "Unexpected value passed to skip-empty flag: #{value}"
            end
            opts[:skip_empty] = true
          else
            raise ArgumentError, "Invalid option: #{key}"
          end
        end

        opts
      end
    end
  end
end
