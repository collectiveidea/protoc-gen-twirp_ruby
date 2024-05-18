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
end
