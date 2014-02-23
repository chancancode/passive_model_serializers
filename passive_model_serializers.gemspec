$:.unshift File.expand_path("../lib", __FILE__)
require "passive_model/serializer/version"

Gem::Specification.new do |gem|
  gem.authors       = ["Godfrey Chan"]
  gem.email         = ["godfreykfc@gmail.com"]
  gem.description   = %q{An experiment to to make ActiveModel::Serializers more flexible}
  gem.summary       = %q{An experiment to to make ActiveModel::Serializers more flexible}
  gem.homepage      = "https://github.com/chancancode/passive_model_serializers"
  gem.license       = 'MIT'

  gem.files         = Dir['lib/**/*']
  gem.test_files    = Dir['test/**/*']

  gem.name          = "passive_model_serializers"
  gem.require_paths = ["lib"]
  gem.version       = PassiveModel::Serializer::VERSION

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency "activemodel", ">= 3.2"
  gem.add_development_dependency "rails", ">= 3.2"
end