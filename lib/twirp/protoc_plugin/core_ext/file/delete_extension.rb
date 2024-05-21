# frozen_string_literal: true

class File
  # @param filename [String] a filename string (with optional path),
  #   e.g. "some/example/hello.proto"
  # @return [String] the filename (preserving optional path) minus the file extension,
  #   e.g. "some/example/hello"
  def self.delete_extension(filename)
    filename.delete_suffix(File.extname(filename))
  end
end
