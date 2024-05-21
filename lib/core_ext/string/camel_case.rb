# frozen_string_literal: true

require "core_ext/string/capitalize_first"

class String
  # Returns the string converted to either lowerCamelCase or UpperCamelCase.
  #
  # Inspired by https://github.com/rails/rails/blob/6f0d1ad14b92b9f5906e44740fce8b4f1c7075dc/activesupport/lib/active_support/inflector/methods.rb#L70
  #
  # @param uppercase_first_letter [Boolean] true for UpperCamelCase,
  #   false for lowerCamelCase. Defaults to true.
  # @return [String] a copy of the chars of <code>self</code>
  def camel_case(uppercase_first_letter = true)
    s = if uppercase_first_letter
      capitalize_first
    else
      self
    end

    s.gsub(/_([a-z\d]*)/i) do
      $1.capitalize
    end
  end
end
