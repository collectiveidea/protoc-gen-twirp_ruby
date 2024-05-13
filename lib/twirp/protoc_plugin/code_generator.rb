# frozen_string_literal: true

require_relative "../../google/protobuf/compiler/plugin_pb"
require_relative "../../core_ext/string/camel_case"
require "stringio"

module Twirp
  module ProtocPlugin
    class CodeGenerator
      # @param proto_file [Google::Protobuf::FileDescriptorProto]
      # @param relative_ruby_protobuf [String] e.g. "example_rb.pb"
      def initialize(proto_file, relative_ruby_protobuf)
        @proto_file = proto_file
        @relative_ruby_protobuf = relative_ruby_protobuf
      end

      # @return [String] the generated Twirp::Ruby code for the proto_file
      def generate
        output = StringIO.new
        output << <<~START
          # frozen_string_literal: true
          
          # Generated by the protoc-gen-twirp_ruby gem v#{VERSION}. DO NOT EDIT!
          # source: #{@proto_file.name}

          require "twirp"
          require_relative "#{@relative_ruby_protobuf}"
      
        START

        indent_level = 0
        modules = split_to_constants(@proto_file.package)

        modules.each do |mod|
          output << line("module #{mod}", indent_level)
          indent_level += 1
        end

        current_module = "::" + modules.join("::")

        @proto_file.service.each_with_index do |service, index| # service: <Google::Protobuf::ServiceDescriptorProto>
          # Add newline between service definitions when multiple are generated
          output << "\n" if index > 0

          service_name = service.name
          # The generated service class name should end in "Service"; Only append the
          # suffix if the service is not already well-named.
          service_class_name = if service_name.end_with?("Service")
            service_name
          else
            service_name + "Service"
          end
          service_class_name = service_class_name.camel_case

          # Generate service class
          output << line("class #{service_class_name} < ::Twirp::Service", indent_level)
          output << line("  package \"#{@proto_file.package}\"", indent_level) unless @proto_file.package.to_s.empty?
          output << line("  service \"#{service_name}\"", indent_level)
          service["method"].each do |method| # method: <Google::Protobuf::MethodDescriptorProto>
            input_type = convert_to_ruby_type(method.input_type, current_module)
            output_type = convert_to_ruby_type(method.output_type, current_module)
            ruby_method_name = snake_case(method.name)

            output << line("  rpc :#{method.name}, #{input_type}, #{output_type}, ruby_method: :#{ruby_method_name}", indent_level)
          end
          output << line("end", indent_level)

          # Generate client class

          # Strip the "Service" suffix if present for better readability.
          client_class_name = (service_name.delete_suffix("Service") + "Client").camel_case

          output << "\n"
          output << line("class #{client_class_name} < ::Twirp::Client", indent_level)
          output << line("  client_for #{service_class_name}", indent_level)
          output << line("end", indent_level)
        end

        modules.each do |_|
          indent_level -= 1
          output << line("end", indent_level)
        end

        output.string
      end

      private

      # Format a string by adding a trailing new line and indenting 2 spaces
      # for every indent level.
      #
      # @param input [String] the input string to format
      # @param indent_level [Integer] the number of double spaces to indent. Default 0.
      # @return [String] the input properly indented with a tailing newline added
      def line(input, indent_level = 0)
        "#{"  " * indent_level}#{input}\n"
      end

      # Converts either a package string like ".some.example.api" or a namespaced
      # message like "google.protobuf.Empty" to an Array of Strings that can be
      # used as Ruby constants (when joined with "::").
      #
      # ".some.example.api" becomes ["", Some", "Example", "Api"]
      # "google.protobuf.Empty" becomes ["Google", "Protobuf", "Empty"]
      #
      # @param package_or_message [String]
      # @return [Array<String>]
      def split_to_constants(package_or_message)
        package_or_message
          .split(".")
          .map { |s| s.camel_case }
      end

      # Converts a protobuf message type to a string containing
      # the equivalent Ruby constant.
      #
      # Examples:
      #
      #   convert_to_ruby_type("example_message") => "ExampleMessage"
      #   convert_to_ruby_type(".foo.bar.example_message") => "::Foo::Bar::ExampleMessage"
      #   convert_to_ruby_type(".foo.bar.example_message", "::Foo") => "Bar::ExampleMessage"
      #   convert_to_ruby_type(".foo.bar.example_message", "::Foo::Bar") => "ExampleMessage"
      #   convert_to_ruby_type("google.protobuf.Empty", "::Foo") => "Google::Protobuf::Empty"
      #
      # @param message_type [String]
      # @param current_module [String, nil]
      # @return [String]
      def convert_to_ruby_type(message_type, current_module = nil)
        s = split_to_constants(message_type).join("::")

        if !current_module.nil? && s.start_with?(current_module)
          # Strip current module and trailing "::" prefix
          s[current_module.size + 2..]
        else
          s
        end
      end

      # Converts input to lower_snake_case.
      #
      # Inspired by https://github.com/rails/rails/blob/6f0d1ad14b92b9f5906e44740fce8b4f1c7075dc/activesupport/lib/active_support/inflector/methods.rb#L99
      #
      # @param input [String] the input string to convert to lower_snake_case
      # @return [String] the converted input
      def snake_case(input)
        input
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end
    end
  end
end
