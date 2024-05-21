# frozen_string_literal: true

class String
  # Capitalizes the first letter of the string.
  #
  # Inspired by https://github.com/rails/rails/blob/6f0d1ad14b92b9f5906e44740fce8b4f1c7075dc/activesupport/lib/active_support/inflector/methods.rb#L166
  #
  # @return [String] a string with the first letter capitalized
  def capitalize_first
    return "" if empty?

    self[0].upcase + self[1..]
  end
end
