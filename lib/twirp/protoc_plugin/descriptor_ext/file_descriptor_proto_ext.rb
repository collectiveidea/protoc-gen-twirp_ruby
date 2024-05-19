# frozen_string_literal: true

require "google/protobuf/descriptor_pb"
require "twirp/protoc_plugin/core_ext/string/camel_case"

class Google::Protobuf::FileDescriptorProto
  # The `FileDescriptorProto` contains a `dependency` array of all of the imported file
  # name strings, in the order in which they appear in the source file.
  #
  # We want to create a parallel array, but instead of just the file names, we want
  # the _references_ to those proto file descriptors. So, we declare the attribute
  # here. NOTE: We also override `CodeGeneratorRequest` `decode` such that it automatically
  # populates this array when the request is decoded.
  #
  # @return [Array<Google::Protobuf::FileDescriptorProto>]
  attr_accessor :dependency_proto_files

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

  # @return [String] the ruby module for this proto file. Gives precedence to
  #   the `ruby_package` option if specified, then the `package` of the file
  #   (converted to UpperCamelCase). Includes a leading top-level namespace
  #   qualifier "::", e.g.: "::MyCompany::Example::Api". Returns `""` when neither
  #   ruby_package nor package is specified.
  def ruby_module
    @ruby_module ||= begin
      pkg = options.ruby_package unless options&.ruby_package.to_s.empty?
      pkg ||= split_to_constants(package).join("::").to_s unless package.to_s.empty?

      if pkg.nil?
        "" # Set to "" instead of nil to properly memoize and avoid re-calculating
      else
        "::" + pkg
      end
    end
  end

  # Converts a protobuf message type to a string containing the equivalent Ruby constant,
  # relative to the current proto file's Ruby module.
  #
  # Respects the `ruby_package` option, both for the current proto file and for all
  # message types that are imported if the imported file also specifies a `ruby_package`.
  #
  # For example, given ...
  #
  #   1) the current file has `package "foo.bar";` and `option ruby_package = "Foo::Bar";`
  #   2) an imported file has `package "other.file.baz";` and `option ruby_package = "Baz";`
  #   3) a third imported file has `package "third.file";` without a `ruby_package` option.
  #
  # ... then:
  #
  #   convert_to_ruby_type(".foo.bar.example_message") => "ExampleMessage"
  #   convert_to_ruby_type(".foo.bar.ExampleMessage.NestedMessage") => "ExampleMessage::NestedMessage"
  #   convert_to_ruby_type(".google.protobuf.Empty") => "::Google::Protobuf::Empty"
  #   convert_to_ruby_type(".other.file.baz.example_message") => "::Baz::ExampleMessage"
  #   convert_to_ruby_type(".third.file.example_message") => "::Third::File::ExampleMessage"
  #
  # @param message_type [String]
  # @return [String]
  def convert_to_ruby_type(message_type)
    ruby_type = ruby_type_map[message_type]

    # For types in the same module, remove module and trailing "::"
    ruby_type = ruby_type.delete_prefix(ruby_module + "::") unless ruby_module.empty?

    ruby_type
  end

  private

  # Converts either a package string like ".some.example.api" or a namespaced
  # message like ".google.protobuf.Empty" to an Array of Strings that can be
  # used as Ruby constants (when joined with "::").
  #
  # ".some.example.api" becomes ["", Some", "Example", "Api"]
  # ".google.protobuf.Empty" becomes ["", Google", "Protobuf", "Empty"]
  #
  # @param package_or_message [String]
  # @return [Array<String>]
  def split_to_constants(package_or_message)
    package_or_message
      .split(".")
      .map { |s| s.camel_case }
  end

  # @return [Hash<String, String>] the type mappings for the proto file (and all
  #   imported proto files), keyed by the the protobuf name (starting with `.` when
  #   package is specified). Values correspond to the fully qualified Ruby
  #   type, respecting the `ruby_package` option of the file if present.
  #
  #   For example:
  #     ".example_message" => "ExampleMessage"
  #     ".foo.bar.ExampleMessage => "::Foo::Bar::ExampleMessage"
  #     ".foo.bar.ExampleMessage.NestedMessage" => "::Foo::Bar::ExampleMessage::NestedMessage"
  #     ".google.protobuf.Empty" => "Google::Protobuf::Empty"
  #     ".common.bar.baz.other_type" => "::Common::Baz::OtherType"
  #       (when type is imported from a proto file with package = "common.bar.baz"
  #       and `option ruby_package = "Common::Baz";` specified)
  def ruby_type_map
    if @ruby_type_map.nil?
      @ruby_type_map = build_ruby_type_map(self)
    end

    @ruby_type_map
  end

  # Loops through the messages in the proto file, and recurses through the messages in
  # dependent proto files, to construct the ruby type map for all types within the file.
  #
  # @see [#ruby_type_map]
  # @param proto_file [Google::Protobuf::FileDescriptorProto]
  # @return [Hash<String, String>]
  def build_ruby_type_map(proto_file)
    type_map = {}

    proto_file.message_type.each do |message_type|
      add_message_type(type_map, proto_file, message_type)
    end

    proto_file.dependency_proto_files.each do |dependency_proto_file|
      type_map.merge! build_ruby_type_map(dependency_proto_file)
    end

    type_map
  end

  # Adds the message type's key and value to the type map, recursively handling nested message
  # types along the way.
  #
  # @param type_map [Hash<String, String>]
  # @param proto_file [Google::Protobuf::FileDescriptorProto] The proto file containing the message type
  # @param message_type [Google::Protobuf::DescriptorProto]
  # @param parent_key [String, nil] In the recursive case, this is the parent message type key so
  #   that the nested child type can be properly namespaced.
  # @param parent_value [String, nil] In the recursive case, this is the parent message type value
  #   so that the nested type can be properly namespaced.
  # @return [void]
  def add_message_type(type_map, proto_file, message_type, parent_key = nil, parent_value = nil)
    key = if !parent_key.nil?
      "#{parent_key}.#{message_type.name}"
    elsif proto_file.package.to_s.empty?
      ".#{message_type.name}"
    else
      ".#{proto_file.package}.#{message_type.name}"
    end

    value = if !parent_value.nil?
      "#{parent_value}::#{message_type.name.camel_case}"
    elsif proto_file.ruby_module.empty?
      message_type.name.camel_case
    else
      "#{proto_file.ruby_module}::#{message_type.name.camel_case}"
    end

    type_map[key] = value

    # Recurse over nested types, using the current message_type's key and value as the parent values
    message_type.nested_type.each do |nested_type|
      add_message_type(type_map, proto_file, nested_type, key, value)
    end
  end
end
