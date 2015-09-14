# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bank_client/version'

Gem::Specification.new do |spec|
  spec.name          = "bank_client"
  spec.version       = BankClient::VERSION
  spec.authors       = ["Ivan Kuznetsov"]
  spec.email         = ["me@jeiwan.ru"]

  spec.summary       = %q{A client for one secret bank}
  spec.description   = %q{A client for one secret bank}
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "gyoku"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "nori"
  spec.add_runtime_dependency "hex_string"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
end
