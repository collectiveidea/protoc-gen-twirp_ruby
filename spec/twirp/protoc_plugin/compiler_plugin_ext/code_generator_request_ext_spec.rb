# frozen_string_literal: true

RSpec.describe Google::Protobuf::Compiler::CodeGeneratorRequest do
  describe ".decode" do
    context "when there are imported proto files" do
      # Fixture reused from `process_spec.rb`
      let(:api_code_gen_request_pb) { fixture("complex_example/api_code_gen_request_pb.bin").read }

      it "populates `dependency_proto_files` with proto files corresponding to the `dependency` array" do
        request = Google::Protobuf::Compiler::CodeGeneratorRequest.decode(api_code_gen_request_pb)

        expect(request.proto_file.size).to eq(6)

        empty_proto = request.proto_file[0]
        expect(empty_proto.name).to eq("google/protobuf/empty.proto")
        expect(empty_proto.dependency).to eq([])
        expect(empty_proto.dependency_proto_files).to eq([])

        any_proto = request.proto_file[1]
        expect(any_proto.name).to eq("google/protobuf/any.proto")
        expect(any_proto.dependency).to eq([])
        expect(any_proto.dependency_proto_files).to eq([])

        status_proto = request.proto_file[2]
        expect(status_proto.name).to eq("common/rpc/status.proto")
        expect(status_proto.dependency).to eq(["google/protobuf/any.proto"])
        expect(status_proto.dependency_proto_files.size).to eq(1)
        expect(status_proto.dependency_proto_files[0]).to eq(any_proto)
        expect(status_proto.dependency_proto_files[0].class).to eq(Google::Protobuf::FileDescriptorProto)
        expect(status_proto.dependency_proto_files[0].name).to eq("google/protobuf/any.proto")

        color_proto = request.proto_file[3]
        expect(color_proto.name).to eq("common/type/color.proto")
        expect(color_proto.dependency).to eq([])
        expect(color_proto.dependency_proto_files).to eq([])

        time_of_day_proto = request.proto_file[4]
        expect(time_of_day_proto.name).to eq("common/type/time_of_day.proto")
        expect(time_of_day_proto.dependency).to eq([])
        expect(time_of_day_proto.dependency_proto_files).to eq([])

        api_proto = request.proto_file[5]
        expect(api_proto.name).to eq("api.proto")
        expect(api_proto.dependency).to eq(%w[
          google/protobuf/empty.proto
          common/rpc/status.proto
          common/type/color.proto
          common/type/time_of_day.proto
        ])

        expect(api_proto.dependency_proto_files.size).to eq(4)

        expect(api_proto.dependency_proto_files[0]).to eq(empty_proto)
        expect(api_proto.dependency_proto_files[0].class).to eq(Google::Protobuf::FileDescriptorProto)
        expect(api_proto.dependency_proto_files[0].name).to eq("google/protobuf/empty.proto")

        expect(api_proto.dependency_proto_files[1]).to eq(status_proto)
        expect(api_proto.dependency_proto_files[1].class).to eq(Google::Protobuf::FileDescriptorProto)
        expect(api_proto.dependency_proto_files[1].name).to eq("common/rpc/status.proto")
        # Not strictly necessary to expect these here because of `eq(status_proto)` above,
        # but it's helpful to demonstrate that deep references are intact here.
        expect(api_proto.dependency_proto_files[1].dependency_proto_files.size).to eq(1)
        expect(api_proto.dependency_proto_files[1].dependency_proto_files[0]).to eq(any_proto)

        expect(api_proto.dependency_proto_files[2]).to eq(color_proto)
        expect(api_proto.dependency_proto_files[2].class).to eq(Google::Protobuf::FileDescriptorProto)
        expect(api_proto.dependency_proto_files[2].name).to eq("common/type/color.proto")

        expect(api_proto.dependency_proto_files[3]).to eq(time_of_day_proto)
        expect(api_proto.dependency_proto_files[3].class).to eq(Google::Protobuf::FileDescriptorProto)
        expect(api_proto.dependency_proto_files[3].name).to eq("common/type/time_of_day.proto")
      end
    end

    context "where there are no imported proto files" do
      # Fixture reused from `process_spec.rb`
      let(:service_code_gen_request_pb) { fixture("service_code_gen_request_pb.bin").read }

      it "creates `dependency_proto_files` as an empty array matching the `dependency` array" do
        request = Google::Protobuf::Compiler::CodeGeneratorRequest.decode(service_code_gen_request_pb)

        expect(request.proto_file.size).to eq 1

        expect(request.proto_file.first.dependency_proto_files).to eq []
        expect(request.proto_file.first.dependency).to eq []
      end
    end
  end
end
