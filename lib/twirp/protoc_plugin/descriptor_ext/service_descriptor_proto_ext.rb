# frozen_string_literal: true

require "google/protobuf/descriptor_pb"
require "twirp/protoc_plugin/core_ext/string/camel_case"

class Google::Protobuf::ServiceDescriptorProto
  def service_class_name
    # The generated service class name should end in "Service"; A well-named
    # service may already end with "Service" but we can't guarantee it. Use
    # class_name_without_service_suffix to #avoid "ServiceService"
    class_name_without_service_suffix + "Service"
  end

  def client_class_name
    class_name_without_service_suffix + "Client"
  end

  private

  def class_name_without_service_suffix
    name.delete_suffix("Service").camel_case
  end
end
