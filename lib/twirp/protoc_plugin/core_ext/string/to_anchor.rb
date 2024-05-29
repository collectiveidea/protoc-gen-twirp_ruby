# frozen_string_literal: true

class String
  # Converts the string to an acceptable URL anchor.
  #
  # Thw rules for GitHub markdown links are:
  #   - force lowercase
  #   - strip punctuation
  #   - replace spaces with dashes
  # @return [String] the string converted to an acceptable URL anchor
  def to_anchor
    downcase.gsub(/[^a-z0-9_ -]/, "").tr(" ", "-")
  end
end
