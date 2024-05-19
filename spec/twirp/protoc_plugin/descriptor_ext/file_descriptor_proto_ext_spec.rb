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
    it "returns an empty string when no package is present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto")
      expect(proto_file.ruby_module).to eq("")
    end

    it "returns the converted package name when present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(name: "hello.proto", package: "my_company.example.api")
      expect(proto_file.ruby_module).to eq("::MyCompany::Example::Api")
    end

    it "returns the ruby_package when both ruby_package option and package present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "hello.proto",
        package: "my_company.example.api",
        options: Google::Protobuf::FileOptions.new(ruby_package: "My::API")
      )

      expect(proto_file.ruby_module).to eq("::My::API")
    end

    it "returns the ruby_package when no package present" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "hello.proto",
        options: Google::Protobuf::FileOptions.new(ruby_package: "My::API")
      )

      expect(proto_file.ruby_module).to eq("::My::API")
    end

    it "returns the converted package when ruby_package is specified but empty" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "hello.proto",
        package: "is.specified",
        options: Google::Protobuf::FileOptions.new(ruby_package: "")
      )

      expect(proto_file.ruby_module).to eq("::Is::Specified")
    end

    it "returns an empty string when both ruby_package and package are empty" do
      proto_file = Google::Protobuf::FileDescriptorProto.new(
        name: "hello.proto",
        package: "",
        options: Google::Protobuf::FileOptions.new(ruby_package: "")
      )

      expect(proto_file.ruby_module).to eq("")
    end
  end

  describe "#convert_to_ruby_type" do
    before do
      # TRICKY: We're not creating via `CodeGeneratorRequest.decode` so we need be sure
      # to set this to an empty array here.
      file_descriptor_proto.dependency_proto_files = []
    end

    context "when the file descriptor does not specify a package" do
      let(:file_descriptor_proto) do
        Google::Protobuf::FileDescriptorProto.new(
          message_type: [
            Google::Protobuf::DescriptorProto.new(
              name: "example_message"
            )
          ]
        )
      end

      it "generates the expected output" do
        type = file_descriptor_proto.convert_to_ruby_type(".example_message")
        expect(type).to eq("ExampleMessage")
      end
    end

    context "when the file descriptor does not specify a package and has a nested type" do
      let(:file_descriptor_proto) do
        Google::Protobuf::FileDescriptorProto.new(
          message_type: [
            Google::Protobuf::DescriptorProto.new(
              name: "ExampleMessage",
              nested_type: [
                Google::Protobuf::DescriptorProto.new(
                  name: "NestedMessage"
                )
              ]
            )
          ]
        )
      end

      it "generates the expected output" do
        type = file_descriptor_proto.convert_to_ruby_type(".ExampleMessage.NestedMessage")
        expect(type).to eq("ExampleMessage::NestedMessage")
      end
    end

    context "when the file descriptor references a dependency that does not specify a ruby_package" do
      let(:google_protobuf_empty_descriptor) do
        Google::Protobuf::FileDescriptorProto.new(
          package: "google.protobuf",
          message_type: [
            Google::Protobuf::DescriptorProto.new(
              name: "Empty"
            )
          ]
        )
      end

      before do
        google_protobuf_empty_descriptor.dependency_proto_files = []

        file_descriptor_proto.dependency_proto_files << google_protobuf_empty_descriptor
      end

      context "when the file descriptor does not specify a package" do
        let(:file_descriptor_proto) do
          Google::Protobuf::FileDescriptorProto.new(
            dependency: ["google/protobuf/empty.proto"],
            message_type: [
              Google::Protobuf::DescriptorProto.new(
                name: "ExampleMessage"
              )
            ]
          )
        end

        it "works for a message within the file" do
          type = file_descriptor_proto.convert_to_ruby_type(".ExampleMessage")
          expect(type).to eq("ExampleMessage")
        end

        it "works with a package outside of the current module" do
          type = file_descriptor_proto.convert_to_ruby_type(".google.protobuf.Empty")
          expect(type).to eq("::Google::Protobuf::Empty")
        end
      end

      context "when the file descriptor specifies a package" do
        let(:file_descriptor_proto) do
          Google::Protobuf::FileDescriptorProto.new(
            package: "foo.bar",
            dependency: ["google/protobuf/empty.proto"],
            message_type: [
              Google::Protobuf::DescriptorProto.new(
                name: "ExampleMessage"
              )
            ]
          )
        end

        it "works for a message in the same package" do
          type = file_descriptor_proto.convert_to_ruby_type(".foo.bar.ExampleMessage")
          expect(type).to eq("ExampleMessage")
        end

        it "works with a package outside of the current module" do
          type = file_descriptor_proto.convert_to_ruby_type(".google.protobuf.Empty")
          expect(type).to eq("::Google::Protobuf::Empty")
        end
      end

      context "when the file descriptor specifies a package and the ruby_package option" do
        let(:file_descriptor_proto) do
          Google::Protobuf::FileDescriptorProto.new(
            package: "foo.bar",
            dependency: ["google/protobuf/empty.proto"],
            options: Google::Protobuf::FileOptions.new(ruby_package: "BAZ"),
            message_type: [
              Google::Protobuf::DescriptorProto.new(
                name: "example_message"
              )
            ]
          )
        end

        it "works for a message in the same package" do
          type = file_descriptor_proto.convert_to_ruby_type(".foo.bar.example_message")
          # No ::BAZ::ExampleMessage here because, while we specify a ruby package, the message is
          # in the same package so we drop the ruby module.
          expect(type).to eq("ExampleMessage")
        end

        it "works with a package outside of the current module" do
          type = file_descriptor_proto.convert_to_ruby_type(".google.protobuf.Empty")
          expect(type).to eq("::Google::Protobuf::Empty")
        end
      end
    end

    context "when the file descriptor references a dependency that specifies a ruby_package" do
      let(:other_file_descriptor) do
        Google::Protobuf::FileDescriptorProto.new(
          package: "other.file.baz",
          options: Google::Protobuf::FileOptions.new(ruby_package: "Baz"),
          message_type: [
            Google::Protobuf::DescriptorProto.new(
              name: "ExampleMessage"
            )
          ]
        )
      end

      let(:file_descriptor_proto) do
        Google::Protobuf::FileDescriptorProto.new(
          name: "hello.proto",
          dependency: ["baz.proto"],
          options: Google::Protobuf::FileOptions.new(ruby_package: "")
        )
      end

      before do
        other_file_descriptor.dependency_proto_files = []

        file_descriptor_proto.dependency_proto_files << other_file_descriptor
      end

      it "uses the other file's ruby package when reference a message in the other file" do
        type = file_descriptor_proto.convert_to_ruby_type(".other.file.baz.ExampleMessage")
        expect(type).to eq("::Baz::ExampleMessage")
      end
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
