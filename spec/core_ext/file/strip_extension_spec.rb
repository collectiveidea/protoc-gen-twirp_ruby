# frozen_string_literal: true

require "core_ext/file/strip_extension"

RSpec.describe File do
  describe ".strip_extension" do
    it "strips the extension and preserves the path" do
      output = File.strip_extension("spec/fixtures/hello.proto")
      expect(output).to eq("spec/fixtures/hello")
    end

    it "strips the extension for a filename without a path" do
      output = File.strip_extension("hello.proto")
      expect(output).to eq("hello")
    end
  end
end
