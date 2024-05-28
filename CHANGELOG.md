## [Unreleased]

- Make `skip-empty` the default behavior; remove recognizing the option flag - [#40](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/40) 
- Update GitHub action to run specs on all supported Ruby versions - [#37](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/37)

## [1.1.1] - 2024-05-22

- Remove unnecessary `racc` runtime dependency - [#33](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/33)

## [1.1.0] - 2024-05-21

- Add support for `ruby_package` option in proto files for generated output - [#28](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/28)
- Update to `protoc` 26.1 to generate the plugin interface Ruby messages - [#27](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/27)
- Add `generate=<service|client|both>` option to customize generated output - [#23](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/23)
- Add `skip-empty` option to prevent generating empty scaffolding for proto files without services - [#21](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/21) 
- Refactor code generator to improve internal readability - [#12](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/12), [#13](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/13), [#22](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/22), [#25](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/25)
- Remove unnecessary extra files from packaged gem - [#11](https://github.com/collectiveidea/protoc-gen-twirp_ruby/pull/11)

## [1.0.0] - 2024-05-10

- Initial release
