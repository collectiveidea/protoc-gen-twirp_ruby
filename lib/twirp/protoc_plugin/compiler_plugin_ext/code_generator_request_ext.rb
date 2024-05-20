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

  # Access the [`Google::Protobuf::RepeatedField`] of [Google::Protobuf::FileDescriptorProto]
  # as a proper Array, memoizing the value in the process.
  #
  # This memoized value stabilizes the test suite when run via `rake spec` (whereas, interestingly,
  # running standalone `rspec` was fine). I'm not certain why that is, but I wonder if it has to
  # do with memory pressure and garbage collection that runs during `rake spec` but not `rspec`
  # (because `rspec` loads less into memory)... and memoizing the value forces the GC to keep the
  # `FileDescriptorProto` references around.
  #
  # Before this change, the `populate_dependency_proto_files!` method would execute and modify
  # the `file_descriptor_proto`, but sometimes the changes inside the enumerator wouldn't "stick"
  # after the enumeration went out of scope. (Again, only via the `rake spec` command, not via
  # `rspec`). This resulted in the `dependency_proto_files` value being unexpectedly `nil` when at
  # the very least an empty array was expected.
  #
  # @return [Array<Google::Protobuf::FileDescriptorProto>]
  def proto_files
    @proto_files ||= proto_file.to_ary
  end

  def populate_dependency_proto_files!
    proto_files.each do |file_descriptor_proto|
      file_descriptor_proto.dependency_proto_files = []

      file_descriptor_proto.dependency.each do |dependent_file_name|
        file_descriptor_proto.dependency_proto_files << proto_file_for(dependent_file_name)
      end
    end
  end

  # @param name [String]
  # @return [Google::Protobuf::FileDescriptorProto, nil]
  def proto_file_for(name)
    proto_files.find { |proto_file| proto_file.name == name }
  end
end
