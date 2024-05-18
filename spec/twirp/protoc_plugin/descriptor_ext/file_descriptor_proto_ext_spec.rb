# frozen_string_literal: true

RSpec.describe Google::Protobuf::FileDescriptorProto do
  describe "#twirp_output_filename" do
    it "returns the correct twirp filename with path in tact" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "spec/fixtures/hello.proto")
      expect(proto_file.twirp_output_filename).to eq("spec/fixtures/hello_twirp.rb")
    end

    it "returns the correct twirp filename when no path present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto")
      expect(proto_file.twirp_output_filename).to eq("hello_twirp.rb")
    end
  end

  describe "#relative_ruby_protobuf_name" do
    it "returns the correct ruby relative filename when path is present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "spec/fixtures/hello.proto")
      expect(proto_file.relative_ruby_protobuf_name).to eq("hello_pb")
    end

    it "returns the correct ruby relative filename when no path present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto")
      expect(proto_file.relative_ruby_protobuf_name).to eq("hello_pb")
    end
  end

  describe "#has_service?" do
    it "returns false when there are no services" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "dummy.proto")
      expect(proto_file.has_service?).to eq(false)
    end

    it "returns true when there there is one service" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "dummy.proto",
        service: [Google::Protobuf::ServiceDescriptorProto.new]
      )
      expect(proto_file.has_service?).to eq(true)
    end

    it "returns true when there there are multiple services" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "dummy.proto",
        service: [Google::Protobuf::ServiceDescriptorProto.new, Google::Protobuf::ServiceDescriptorProto.new]
      )
      expect(proto_file.has_service?).to eq(true)
    end
  end

  describe "#ruby_module" do
    it "returns nil when no package is present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto")
      expect(proto_file.ruby_module).to be_nil
    end

    it "returns the converted package name when present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto", package: "my_company.example.api")
      expect(proto_file.ruby_module).to eq("::MyCompany::Example::Api")
    end
  end

  describe "#convert_to_ruby_type" do
    let(:file_descriptor_proto) { Google::Protobuf::FileDescriptorProto.new }

    it "works without a package" do
      type = file_descriptor_proto.convert_to_ruby_type("example_message")
      expect(type).to eq("ExampleMessage")
    end

    it "works with a package and without a module" do
      type = file_descriptor_proto.convert_to_ruby_type(".foo.bar.example_message")
      expect(type).to eq("::Foo::Bar::ExampleMessage")
    end

    it "works with a package and top-level module" do
      type = file_descriptor_proto.convert_to_ruby_type(".foo.bar.example_message", "::Foo")
      expect(type).to eq("Bar::ExampleMessage")
    end

    it "works with a package and top-level nested module" do
      type = file_descriptor_proto.convert_to_ruby_type(".foo.bar.example_message", "::Foo::Bar")
      expect(type).to eq("ExampleMessage")
    end

    it "works with a package outside of the current module" do
      type = file_descriptor_proto.convert_to_ruby_type("google.protobuf.Empty", "::Foo")
      expect(type).to eq("Google::Protobuf::Empty")
    end
  end

  describe "#split_to_constants" do
    let(:file_descriptor_proto) { Google::Protobuf::FileDescriptorProto.new }
    def call_private_method_with(message_type)
      file_descriptor_proto.send(:split_to_constants, message_type)
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
end
