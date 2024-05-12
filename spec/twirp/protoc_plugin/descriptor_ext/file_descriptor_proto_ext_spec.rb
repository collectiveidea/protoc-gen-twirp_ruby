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
end
