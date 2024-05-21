# frozen_string_literal: true

require "core_ext/string/camel_case"
require "google/protobuf/descriptor_pb"

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

  # @return [String] the ruby module for this proto file. This is the `package` of
  #   the file (converted to UpperCamelCase), with a leading top-level namespace
  #   qualifier "::", e.g.: "::MyCompany::Example::Api". Returns `nil` when no
  #   package is specified.
  def ruby_module
    return nil if package.to_s.empty?

    @ruby_module ||= "::" + split_to_constants(package).join("::")
  end

  # Converts a protobuf message type to a string containing
  # the equivalent Ruby constant.
  #
  # Examples:
  #
  #   convert_to_ruby_type("example_message") => "ExampleMessage"
  #   convert_to_ruby_type(".foo.bar.example_message") => "::Foo::Bar::ExampleMessage"
  #   convert_to_ruby_type(".foo.bar.example_message", "::Foo") => "Bar::ExampleMessage"
  #   convert_to_ruby_type(".foo.bar.example_message", "::Foo::Bar") => "ExampleMessage"
  #   convert_to_ruby_type("google.protobuf.Empty", "::Foo") => "Google::Protobuf::Empty"
  #
  # @param message_type [String]
  # @param current_module [String, nil]
  # @return [String]
  def convert_to_ruby_type(message_type, current_module = nil)
    s = split_to_constants(message_type).join("::")

    if !current_module.nil? && s.start_with?(current_module)
      # Strip current module and trailing "::" prefix
      s[current_module.size + 2..]
    else
      s
    end
  end

  private

  # Converts either a package string like ".some.example.api" or a namespaced
  # message like "google.protobuf.Empty" to an Array of Strings that can be
  # used as Ruby constants (when joined with "::").
  #
  # ".some.example.api" becomes ["", Some", "Example", "Api"]
  # "google.protobuf.Empty" becomes ["Google", "Protobuf", "Empty"]
  #
  # @param package_or_message [String]
  # @return [Array<String>]
  def split_to_constants(package_or_message)
    package_or_message
      .split(".")
      .map { |s| s.camel_case }
  end
end
