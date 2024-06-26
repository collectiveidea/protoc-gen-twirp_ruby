[![Gem Version](https://img.shields.io/gem/v/protoc-gen-twirp_ruby.svg)](https://rubygems.org/gems/protoc-gen-twirp_ruby)
[![Specs](https://github.com/collectiveidea/protoc-gen-twirp_ruby/actions/workflows/rspec.yml/badge.svg)](https://github.com/collectiveidea/protoc-gen-twirp_ruby/actions/workflows/rspec.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a0020a73103eedbe760c/test_coverage)](https://codeclimate.com/github/collectiveidea/protoc-gen-twirp_ruby/test_coverage)

# protoc-gen-twirp_ruby - A `protoc` plugin for Twirp-Ruby.

This gem is a `protoc` plugin that generates [Twirp-Ruby](https://github.com/arthurnn/twirp-ruby) services and clients.

## Why use this? 

Twirp-Ruby [already does this](https://github.com/arthurnn/twirp-ruby/tree/main/protoc-gen-twirp_ruby)
via a `go` module. So why use this version? 

* Easier install (just add the gem).
* You already know and love Ruby.
* We're committed to keeping it up to date.

The Go version works fine (we used it for years) but it was missing features that we wanted. Building in Ruby allows us to iterate quicker and makes it easier for others to contribute.

## Installation

### Install `protoc`

The [Protocol Buffers](https://protobuf.dev) `protoc` command is used to auto-generate code from `.proto` files.

 * MacOS: `brew install protobuf`
 * Ubuntu/Debian: `sudo apt-get install -y protobuf`
 * Or download pre-compiled binaries: https://github.com/protocolbuffers/protobuf/releases

`protoc` is able to read `.proto` files and generate the message parsers in multiple languages, including Ruby (using
the `--ruby_out` option). It does not generate Twirp services and clients; that is where our plugin comes in.

### Install the `protoc-gen-twirp_ruby` plugin
 
Run `gem install protoc-gen-twirp_ruby` or add it to your Gemfile:

```ruby
gem "protoc-gen-twirp_ruby", group: :development
```

If you previously used the Go version, see our [Migration Instructions](#migrating-from-the-go-module).

## Usage

Pass `--twirp_ruby_out` to `protoc` to generate Twirp-Ruby code:

```bash
protoc --proto_path=. --ruby_out=. --twirp_ruby_out=. ./path/to/service.proto
```

### Options

You can configure the code generation. Pass options by specifying `--twirp_ruby_opt=<option>` on the `protoc` command line.

 * `generate=<service|client|both>`: Customize generated output to include generated services, clients, or both. Optional,
    defaults to both to preserve backwards compatibility.
   * `generate=service` - only generate `::Twirp::Service`s.
   * `generate=client` - only generate `::Twirp::Client`s.
   * `generate=both` - default; generate both services and clients. 

Example : 

```bash
protoc --proto_path=. --ruby_out=. --twirp_ruby_out=. --twirp_ruby_opt=generate=client ./path/to/service.proto
```

## Migrating from the Go module

If you previously installed the `protoc-gen-twirp_ruby` Go module via the [Twirp-Ruby's Code Generation wiki page](https://github.com/arthurnn/twirp-ruby/wiki/Code-Generation)
instructions, then you'll want to uninstall it before invoking the `protoc` command.

```bash
rm `go env GOPATH`/bin/protoc-gen-twirp_ruby
```

### Differences from the Go module

This gem generates nearly identical Twirp-Ruby output as the Go version. Some notable differences
that might affect migration include:

 * Generated output code is in [standardrb style](https://github.com/standardrb/standard).
 * Generated service and client class names are improved for well-named protobuf services. See [#6](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/6).
 * Supports `ruby_package` in `.proto` files
 * Supports protoc command line [configuration options](#options).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To experiment with development changes, route `protoc` to the local plugin when generating code
via the `--plugin=protoc-gen-twirp_ruby=./exe/protoc-gen-twirp_ruby` option. For example:

```bash
protoc --plugin=protoc-gen-twirp_ruby=./exe/protoc-gen-twirp_ruby --ruby_out=. --twirp_ruby_out=. ./example/hello_world.proto
```

Alternatively, install the local gem before invoking `protoc`:

```bash
bundle exec rake install
protoc --ruby_out=. --twirp_ruby_out=. ./example/hello_world.proto
```

## Releasing

Install the [GitHub CLI](https://cli.github.com): `brew install gh` or [follow the instructions](https://github.com/cli/cli#installation).

To release a new version:

 * Submit a PR with the following changes (see e.g. [#30](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/30)):
   * Update the version number in `version.rb`
   * Update the CHANGELOG.md
     * Create a section for the new version and move the unreleased version there
   * Re-generate the example: `bundle exec rake example`
 * Once merged and `main` is up-to-date, run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/collectiveidea/protoc-gen-twirp_ruby.
