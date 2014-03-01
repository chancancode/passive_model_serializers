require 'test_helper'

module PassiveModel
  class Serializer
    class AttributesTest < Test
      class ProfileSerializer < Serializer
        attributes :name, :description
      end

      class ProfileSerializerWithComments < ProfileSerializer
        attributes :comments
      end

      class CustomProfileSerializer < Serializer
        attributes :name, :custom

        def name
          object.name.downcase
        end

        def custom
          'custom'
        end
      end

      def setup
        @profile = Model.new({
          name: 'Name',
          description: 'Description',
          comments: 'Comments'
        })
      end

      def test_attributes
        expected = {
          name: 'Name',
          description: 'Description'
        }

        assert_serialized expected, ProfileSerializer.new(@profile)
      end

      def test_inheritance
        expected_with_comments = {
          name: 'Name',
          description: 'Description',
          comments: 'Comments'
        }

        assert_serialized expected_with_comments, ProfileSerializerWithComments.new(@profile)
      end

      def test_custom_attributes
        expected_custom = {
          name: 'name',
          custom: 'custom'
        }

        assert_serialized expected_custom, CustomProfileSerializer.new(@profile)
      end
    end
  end
end