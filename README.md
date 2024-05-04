# protoc-gen-twirp_ruby 

This gem provides a `protoc` plugin that generates [Twirp-Ruby](https://github.com/arthurnn/twirp-ruby) services and clients.

**NOTE:** Twirp-Ruby already has a protoc plugin available at https://github.com/arthurnn/twirp-ruby/tree/main/protoc-gen-twirp_ruby and released as a `go` module.
This project creates an alternative plugin written in Ruby that is meant to be a more easily accessible alternative.

## Installation

### Install `protoc`

The [Protocol Buffers](https://protobuf.dev) `protoc` command is used to auto-generate code from `.proto` files.

 * MacOS: `brew install protobuf`
 * Ubuntu/Debian: `sudo apt-get install -y protobuf`
 * Or download pre-compiled binaries: https://github.com/protocolbuffers/protobuf/releases

`protoc` is able to read `.proto` files and generate the message parsers in multiple languages, including Ruby (using the `--ruby_out` option). It does not generate Twirp services and clients; that is where our plugin comes in.

### Install the `protoc-gen-twirp_ruby ` plugin

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add protoc-gen-twirp_ruby --group "development, test"
````

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install protoc-gen-twirp_ruby
```

## Usage

Once `protoc` and the `protoc-gen-twirp_ruby` gem is installed, pass `--twirp_ruby_out` to generate Twirp-Ruby code:

```bash
protoc --proto_path=. --ruby_out=. --twirp_ruby_out=. ./path/to/service.proto
```

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
