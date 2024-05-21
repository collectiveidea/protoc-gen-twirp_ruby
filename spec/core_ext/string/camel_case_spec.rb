# frozen_string_literal: true

require "twirp/protoc_plugin/core_ext/string/camel_case"

RSpec.describe String do
  describe "#camel_case" do
    it "converts to upper camel case" do
      expect("example_input".camel_case).to eq("ExampleInput")
    end

    it "converts to lower camel case" do
      expect("example_input".camel_case(false)).to eq("exampleInput")
    end

    it "works with digits and non-words chars" do
      expect("example_input8_abc-de".camel_case).to eq("ExampleInput8Abc-de")
    end

    it "works with a lowercase after a digit" do
      expect("a2z".camel_case).to eq("A2z")
    end
  end
end
