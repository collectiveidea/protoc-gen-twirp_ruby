# frozen_string_literal: true

require "twirp/protoc_plugin/core_ext/file/delete_extension"
require "google/protobuf/compiler/plugin_pb"
require "twirp/protoc_plugin/compiler_plugin_ext/code_generator_request_ext"
require "twirp/protoc_plugin/descriptor_ext/file_descriptor_proto_ext"
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

        options, warnings = extract_options(request.parameter)

        warnings.each do |warning|
          $stderr << "WARNING: #{warning}"
        end

        response = Google::Protobuf::Compiler::CodeGeneratorResponse.new
        response.supported_features = Google::Protobuf::Compiler::CodeGeneratorResponse::Feature::FEATURE_PROTO3_OPTIONAL

        request.proto_file.each do |proto_file| # proto_file: <Google::Protobuf::FileDescriptorProto>
          next unless request.file_to_generate.include?(proto_file.name)
          next unless proto_file.has_service? # do not generate when no services defined

          file = Google::Protobuf::Compiler::CodeGeneratorResponse::File.new
          file.name = proto_file.twirp_output_filename
          file.content = CodeGenerator.new(proto_file, proto_file.relative_ruby_protobuf_name, options).generate

          response.file << file
        end

        response.to_proto
      end

      private

      # @param params [String] the parameters from `protoc` command line in comma-separated stringified
      #   array format, e.g. "some-flag,key1=value1". For repeated command line options, `protoc` will
      #   add the option multiple times, e.g. "some-flag,key1=value1,key1=twice,key2=value2".
      #
      #   The only valid parameter is currently the optional "generate" parameter.
      #
      # @return [Array(Hash{Symbol => Symbol}, Array<String>?)] the extracted options as the first
      #   element, and an array of any applicable warnings as the second element (or nil when no
      #   warnings are present).
      #
      #   The first return value is a Hash that contains:
      #     * :generate [Symbol] one of: :service, :client, or :both. Default :both.
      #
      # @raise [ArgumentError] when a required parameter is missing, a parameter value is invalid, or
      #   an unrecognized parameter is present on the command line
      def extract_options(params)
        warnings = []
        opts = {
          generate: :both
        }

        # Process the options passed to the plugin from `protoc`.
        params.split(",").each do |param|
          # In the event value contains an =, we want to leave that intact.
          # Limit the split to just separate the key out.
          key, value = param.split("=", 2)
          if key == "skip-empty"
            # Ignore; this is now the default behavior. A future release will remove
            # this flag entirely, and will raise an error instead of a warning.
            warnings << "The `skip-empty` flag is deprecated and will be removed next release; it is now the default behavior."
          elsif key == "generate"
            if value.nil? || value.empty?
              raise ArgumentError, "Unexpected missing value for generate option. Please supply one of: service, client, both."
            end

            value_as_symbol = value&.to_sym
            unless %i[service client both].include?(value_as_symbol)
              raise ArgumentError, "The generate value must be one of: service, client, both. Unexpectedly received: #{value}"
            end

            opts[:generate] = value_as_symbol
          else
            raise ArgumentError, "Invalid option: #{key}"
          end
        end

        [opts, warnings]
      end
    end
  end
end
