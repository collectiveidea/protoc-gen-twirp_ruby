# frozen_string_literal: true

require "twirp/protoc_plugin/core_ext/string/snake_case"

RSpec.describe String do
  describe "#snake_case" do
    it "does nothing when input is already snake_case" do
      expect("example_input".snake_case).to eq("example_input")
    end

    it "converts UpperCamelCase to lower_snake_case" do
      expect("ExampleInputValue".snake_case).to eq("example_input_value")
    end

    it "downcases an titleized input" do
      expect("Example".snake_case).to eq("example")
    end

    it "works with digits and non-words chars" do
      expect("ExampleInput8ABCDef".snake_case).to eq("example_input8_abc_def")
    end
  end
end
