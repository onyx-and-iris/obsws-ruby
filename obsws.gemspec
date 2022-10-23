# frozen_string_literal: true
require File.expand_path("lib/obsws/version", __dir__)
lib = File.expand_path("./lib")

Gem::Specification.new do |spec|
  spec.name = "obsws"
  spec.version = OBSWS::Version
  spec.summary = "OBS Websocket v5 wrapper"
  spec.description = "A Ruby wrapper around OBS Websocket v5"
  spec.authors = ["onyx_online"]
  spec.email = "code@onyxandiris.online"
  spec.files = Dir["lib/**/*.rb"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE"]
  spec.homepage = "https://rubygems.org/gems/obsws"
  spec.license = "MIT"
  spec.add_runtime_dependency "observer", "~> 0.1.1"
  spec.add_runtime_dependency "websocket-driver", "~> 0.7.5"
  spec.add_runtime_dependency "waitutil", "~> 0.2.1"
  spec.add_development_dependency "perfect_toml", "~> 0.9.0"
  spec.add_development_dependency "minitest", "~> 5.16", ">= 5.16.3"
  spec.add_development_dependency "rake", "~> 11.2", ">= 11.2.2"
  spec.required_ruby_version = ">= 3.0"
  spec.metadata = {
    "source_code_uri" => "https://github.com/onyx-and-iris/obsws.git"
  }
end
