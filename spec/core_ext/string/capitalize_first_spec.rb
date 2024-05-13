# frozen_string_literal: true

require "core_ext/string/capitalize_first"

RSpec.describe String do
  describe "#capitalize_first" do
    it "returns an empty string when the string is empty" do
      expect("".capitalize_first).to eq("")
    end

    it "capitalizes the first letter when lowercase" do
      expect("world, Hello".capitalize_first).to eq("World, Hello")
    end

    it "does not alter the string when starting with uppercase" do
      expect("Hello World".capitalize_first).to eq("Hello World")
    end
  end
end
