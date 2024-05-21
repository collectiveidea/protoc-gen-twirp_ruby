# frozen_string_literal: true

require "twirp/protoc_plugin/core_ext/file/delete_extension"

RSpec.describe File do
  describe ".delete_extension" do
    it "strips the extension and preserves the path" do
      output = File.delete_extension("spec/fixtures/hello.proto")
      expect(output).to eq("spec/fixtures/hello")
    end

    it "strips the extension for a filename without a path" do
      output = File.delete_extension("hello.proto")
      expect(output).to eq("hello")
    end
  end
end
