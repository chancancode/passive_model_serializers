require 'bundler/setup'
require 'minitest/autorun'
require 'passive_model_serializers'
require 'fixtures/poro'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

module PassiveModel
  class Test < Minitest::Test
    def assert_serialized(expected, serializer)
      assert_equal expected, serializer.serializable_hash
    end
  end
end