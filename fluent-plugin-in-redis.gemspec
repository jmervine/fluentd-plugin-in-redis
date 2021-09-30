# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-in-redis"
  spec.version       = "0.0.1.pre"
  spec.authors       = ["Joshua Mervine"]
  spec.email         = ["jmervine@mulesoft.com"]
  spec.summary       = %q{Fluentd input plugin for reading events from redis.}

  spec.files         = Dir["lib/**/*"]
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", "~> 1.3", ">= 1.3.2"
  spec.add_runtime_dependency "redis", "~> 4.4", ">= 4.4.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "mock_redis"
  spec.add_development_dependency "test-unit", "~> 3"
end
