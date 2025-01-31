# frozen_string_literal: true

require_relative "lib/rack/idempotency_key/version"

Gem::Specification.new do |spec|
  spec.name = "rack-idempotency_key"
  spec.version = Rack::IdempotencyKey::VERSION
  spec.licenses = ["MIT"]
  spec.authors = ["Matteo Rossi"]
  spec.email = ["mttrss5@gmail.com"]
  spec.summary = "A Rack Middleware implementing the idempotency principle"
  spec.homepage = "https://github.com/matteoredz/rack-idempotency_key"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/matteoredz/rack-idempotency_key"
  spec.metadata["changelog_uri"] = "https://github.com/matteoredz/rack-idempotency_key/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
