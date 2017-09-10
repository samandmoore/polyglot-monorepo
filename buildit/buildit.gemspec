$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "buildit/version"

Gem::Specification.new do |s|
  s.name        = "buildit"
  s.version     = Buildit::VERSION
  s.authors     = ["Sam Moore"]
  s.email       = ["samandmoore@gmail.com"]
  s.homepage    = "https://github.com/samandmoore/buildit"
  s.summary     = "A library to convert buildit yml into circleci yml"
  s.description = "Converts conventional applicaiton yml configurations into CI specific versions."
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "{exe}/**/*", "LICENSE", "README.md"]
  s.test_files = Dir["spec/**/*"]
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.add_dependency "tilt", "~> 2.0.0"
  s.add_dependency "erubi"

  s.add_development_dependency "rspec", "~> 3.5"

  s.required_ruby_version = ">= 2"
end
