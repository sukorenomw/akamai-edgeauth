# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "akamai/edge_auth/version"

Gem::Specification.new do |spec|
  spec.name          = "edge_auth"
  spec.version       = Akamai::EdgeAuth::VERSION
  spec.authors       = ["Sukoreno Mukti"]
  spec.email         = ["sukorenomw@gmail.com"]

  spec.summary       = %q{Akamai EdgeAuth token generator}
  spec.description   = %q{Akamai EdgeAuth token generator for TokenAuth setting in Media Live Streaming Packaging or Segmented Media Protection}
  spec.homepage      = "https://github.com/sukorenomw/akamai_edge_auth"
  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'timecop', '~> 0'
end
