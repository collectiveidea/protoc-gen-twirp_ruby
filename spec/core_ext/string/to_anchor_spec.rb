# frozen_string_literal: true

require "twirp/protoc_plugin/core_ext/string/to_anchor"

RSpec.describe String do
  describe "#to_anchor" do
    it "converts a string with brackets, numbers, and dates" do
      expect("[1.1.1] - 2024-05-22".to_anchor).to eq("111---2024-05-22")
    end

    it "converts a string with mixed case and backticks" do
      expect("Install the `protoc-gen-twirp_ruby` plugin gem".to_anchor).to eq("install-the-protoc-gen-twirp_ruby-plugin-gem")
    end
  end
end
