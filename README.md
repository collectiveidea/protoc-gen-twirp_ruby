[![Gem Version](https://img.shields.io/gem/v/protoc-gen-twirp_ruby.svg)](https://rubygems.org/gems/protoc-gen-twirp_ruby)
[![Build](https://github.com/collectiveidea/protoc-gen-twirp_ruby/actions/workflows/main.yml/badge.svg)](https://github.com/collectiveidea/protoc-gen-twirp_ruby/actions/workflows/main.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)

# protoc-gen-twirp_ruby

This gem provides a `protoc` plugin that generates [Twirp-Ruby](https://github.com/arthurnn/twirp-ruby) services and clients.

**NOTE:** Twirp-Ruby [already has a protoc plugin available](https://github.com/arthurnn/twirp-ruby/tree/main/protoc-gen-twirp_ruby)
released as a `go` module. This project creates an alternative plugin written in Ruby and distributed as a gem that
produces comparable output while being both more familiar and accessible to Ruby developers.

## Installation

### Install `protoc`

The [Protocol Buffers](https://protobuf.dev) `protoc` command is used to auto-generate code from `.proto` files.

 * MacOS: `brew install protobuf`
 * Ubuntu/Debian: `sudo apt-get install -y protobuf`
 * Or download pre-compiled binaries: https://github.com/protocolbuffers/protobuf/releases

`protoc` is able to read `.proto` files and generate the message parsers in multiple languages, including Ruby (using
the `--ruby_out` option). It does not generate Twirp services and clients; that is where our plugin comes in.

### Install the `protoc-gen-twirp_ruby` plugin
 
Install the gem by adding it to your Gemfile:

```ruby
group :development, :test do
  "protoc-gen-twirp_ruby"
end
````

Alternatively, install the gem on your system:

```bash
gem install protoc-gen-twirp_ruby
```

## Migration from the `protoc-gen-twirp_ruby` go module

If you have previously installed the `go` version of the plugin via the [Twirp-Ruby Code Generation wiki page](https://github.com/arthurnn/twirp-ruby/wiki/Code-Generation)
instructions, then you'll want to uninstall it before invoking the `protoc` command.

```bash
rm `go env GOPATH`/bin/protoc-gen-twirp_ruby
```

### Notable plugin differences

This gem generates nearly identical Twirp-Ruby output as the go version plugin. Some notable differences
that might affect migration include:

 * Generated output code is in [standardrb style](https://github.com/standardrb/standard).
 * Generated service and client class names are improved for well-named protobuf services. See [#6](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/6).
 * Supports various protoc command line [configuration options](https://github.com/collectiveidea/protoc-gen-twirp_ruby?tab=readme-ov-file#options).

## Usage

Once `protoc` and the `protoc-gen-twirp_ruby` gem is installed, pass `--twirp_ruby_out` to generate Twirp-Ruby code:

```bash
protoc --proto_path=. --ruby_out=. --twirp_ruby_out=. ./path/to/service.proto
```

### Options

The plugin supports the following options to configure code generation. Pass options by
specifying `--twirp_ruby_opt=<option>` on the `protoc` command line.

 * `skip-empty`: Avoid generating a `_twirp.rb` for a `.proto` with no service definitions. By default, a `_twirp.rb`
   file is generated for every proto file listed on the command line, even if the file is empty scaffolding. 
 * `generate=<service|client|both>`: Customize generated output to include generated services, clients, or both.
   * `generate=service` - only generate `::Twirp::Service` subclass(es).
   * `generate=client` - only generate `::Twirp::Client` subclass(es).
   * `generate=both` - generate both services and clients. This is the default option to preserve
     backwards compatibility.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

For continued development purposes, we can route `protoc` to the local repo code for the plugin and generate against the example via:

```bash
protoc --plugin=protoc-gen-twirp_ruby=./exe/protoc-gen-twirp_ruby --ruby_out=. --twirp_ruby_out=. ./example/hello_world.proto
```

The local code for the gem can also be installed via `bundle exec rake install` to omit the `--plugin=protoc-gen-twirp_ruby=` option from `protoc`:

```bash
bundle exec rake install
protoc --ruby_out=. --twirp_ruby_out=. ./example/hello_world.proto
```

## Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/collectiveidea/protoc-gen-twirp_ruby.
