require 'test_helper'

module PassiveModel
  class Serializer
    class AttributesTest < Minitest::Test
      def setup
        @profile = Model.new(
          name: 'Name',
          description: 'Description',
          comments: 'Comments')

        @profile_serializer_klass = Class.new(PassiveModel::Serializer) do
          attributes :name, :description
        end
      end

      def test_attributes
        assert_equal({name: 'Name', description: 'Description'},
          @profile_serializer_klass.new(@profile).serializable_hash)
      end

      def test_attributes_inheritance
        subklass = Class.new(@profile_serializer_klass)

        subklass_with_comments = Class.new(@profile_serializer_klass) do
          attributes :comments
        end

        assert_equal({name: 'Name', description: 'Description'},
          subklass.new(@profile).serializable_hash)

        assert_equal({name: 'Name', description: 'Description', comments: 'Comments'},
          subklass_with_comments.new(@profile).serializable_hash)
      end
    end
  end
end