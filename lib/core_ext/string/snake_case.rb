# frozen_string_literal: true

class String
  # Converts the string to lower_snake_case.
  #
  # Inspired by https://github.com/rails/rails/blob/6f0d1ad14b92b9f5906e44740fce8b4f1c7075dc/activesupport/lib/active_support/inflector/methods.rb#L99
  #
  # @return [String] the converted input
  def snake_case
    gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .downcase
  end
end
