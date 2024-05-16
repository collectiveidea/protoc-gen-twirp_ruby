# frozen_string_literal: true

class Google::Protobuf::FileDescriptorProto
  # @return [String] the output filename for the proto file's generated twirp code.
  #   For example, given a `name` of e.g. "some/example/hello.proto", the twirp output
  #   filename is "some/example/hello_twirp.rb"
  def twirp_output_filename
    File.delete_extension(name) + "_twirp.rb"
  end

  # @return [String] the file name of the generated ruby protobuf code from protoc,
  #   without any path information and missing the ".rb" file extension.
  #
  #   For example, given a `name` of e.g. "some/example/hello.proto", this helper
  #   returns "hello_rb". The ruby output is expected to be located in the same
  #   directory as the generated twirp output file.
  def relative_ruby_protobuf_name
    File.basename(name, File.extname(name)) + "_pb"
  end

  # @return [Boolean] true if the proto file has at least one `service` definition,
  #   false otherwise.
  def has_service?
    !service.empty?
  end
end
