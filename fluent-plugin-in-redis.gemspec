# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-in-redis"
  spec.version       = "0.0.1"
  spec.authors       = ["Joshua Mervine"]
  spec.email         = ["jmervine@mulesoft.com"]
  spec.summary       = %q{Fluentd input plugin for reading events from redis.}

  spec.files         = Dir["lib/**/*"]
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", "=#{`fluentd --version | awk '{ print $NF }' | xargs`}"
  spec.add_runtime_dependency 'redis', '~> 4.4', '>= 4.4.0'
end
