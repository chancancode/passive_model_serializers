require 'bundler/setup'
require 'minitest/autorun'
require 'passive_model_serializers'
require 'fixtures/poro'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)