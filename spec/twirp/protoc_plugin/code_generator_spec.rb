# frozen_string_literal: true

RSpec.describe Twirp::ProtocPlugin::CodeGenerator do
  # We don't actually cover the `generate` method here; that is covered by
  # the `process_spec.rb`. But, in order to get to the private helper methods
  # to test, we have to stand up an instance that we can send messages to.
  let(:proto_file_descriptor) { Google::Protobuf::FileDescriptorProto.new }
  let(:code_generator) { Twirp::ProtocPlugin::CodeGenerator.new(proto_file_descriptor, "example_rb.pb") }

  describe "#split_to_constants" do
    def call_private_method_with(package_or_message)
      code_generator.send(:split_to_constants, package_or_message)
    end

    it "works with a namespaced message" do
      constants = call_private_method_with("google.protobuf.Empty")
      expect(constants).to eq(%w[Google Protobuf Empty])
    end

    it "works with a package that has a leading dot" do
      constants = call_private_method_with(".some.example.api")
      expect(constants).to eq(%W[#{""} Some Example Api])
    end

    it "works with a top-level message without a package" do
      constants = call_private_method_with("ExampleMessage")
      expect(constants).to eq(%w[ExampleMessage])
    end
  end

  describe "#convert_to_ruby_type" do
    def call_private_method_with(message_type, current_module = nil)
      code_generator.send(:convert_to_ruby_type, message_type, current_module)
    end

    it "works without a package" do
      type = call_private_method_with("example_message")
      expect(type).to eq("ExampleMessage")
    end

    it "works with a package and without a module" do
      type = call_private_method_with(".foo.bar.example_message")
      expect(type).to eq("::Foo::Bar::ExampleMessage")
    end

    it "works with a package and top-level module" do
      type = call_private_method_with(".foo.bar.example_message", "::Foo")
      expect(type).to eq("Bar::ExampleMessage")
    end

    it "works with a package and top-level nested module" do
      type = call_private_method_with(".foo.bar.example_message", "::Foo::Bar")
      expect(type).to eq("ExampleMessage")
    end

    it "works with a package outside of the current module" do
      type = call_private_method_with("google.protobuf.Empty", "::Foo")
      expect(type).to eq("Google::Protobuf::Empty")
    end
  end

  describe "#snake_case" do
    def call_private_method_with(input)
      code_generator.send(:snake_case, input)
    end

    it "does nothing when input is already snake_case" do
      output = call_private_method_with("example_input")
      expect(output).to eq("example_input")
    end

    it "converts UpperCamelCase to lower_snake_case" do
      output = call_private_method_with("ExampleInputValue")
      expect(output).to eq("example_input_value")
    end

    it "downcases an titleized input" do
      output = call_private_method_with("Example")
      expect(output).to eq("example")
    end

    it "works with digits and non-words chars" do
      output = call_private_method_with("ExampleInput8ABCDef")
      expect(output).to eq("example_input8_abc_def")
    end
  end
end
