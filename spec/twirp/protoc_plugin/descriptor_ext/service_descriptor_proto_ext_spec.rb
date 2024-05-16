# frozen_string_literal: true

RSpec.describe Google::Protobuf::ServiceDescriptorProto do
  describe "#service_class_name" do
    it "appends \"Service\" when the service is not well-named" do
      service = Google::Protobuf::ServiceDescriptorProto.new(name: "HelloWorld")
      expect(service.service_class_name).to eq("HelloWorldService")
    end

    it "does not alter the service name when the service is well-named" do
      service = Google::Protobuf::ServiceDescriptorProto.new(name: "HelloWorldService")
      expect(service.service_class_name).to eq("HelloWorldService")
    end
  end
end
