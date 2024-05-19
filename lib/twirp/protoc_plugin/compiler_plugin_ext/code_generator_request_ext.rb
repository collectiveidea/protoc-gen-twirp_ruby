# frozen_string_literal: true

require "google/protobuf/compiler/plugin_pb"
require "twirp/protoc_plugin/descriptor_ext/file_descriptor_proto_ext"

class Google::Protobuf::Compiler::CodeGeneratorRequest
  class << self
    alias_method :old_decode, :decode

    def decode(bytes)
      request = old_decode(bytes)
      request.send(:populate_dependency_proto_files!)

      request
    end
  end

  private

  def populate_dependency_proto_files!
    proto_file.each do |file_descriptor_proto|
      file_descriptor_proto.dependency_proto_files = []

      file_descriptor_proto.dependency.each do |dependent_file_name|
        file_descriptor_proto.dependency_proto_files << proto_file.find { |proto_file| proto_file.name == dependent_file_name }
      end
    end
  end
end
