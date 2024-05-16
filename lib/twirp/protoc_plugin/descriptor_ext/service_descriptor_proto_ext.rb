# frozen_string_literal: true

require_relative "../../../core_ext/string/camel_case"

class Google::Protobuf::ServiceDescriptorProto
  def service_class_name
    # The generated service class name should end in "Service"; But only append the
    # suffix if the service is not already well-named.
    service_class_name = if name.end_with?("Service")
      name
    else
      name + "Service"
    end
    service_class_name.camel_case
  end
end
