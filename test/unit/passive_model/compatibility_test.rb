require 'test_helper'

module PassiveModel
  class Serializer
    class CompatibilityTest < Test
      class Image < Model
      end

      class ProfileSerializer < Serializer
        attributes :name, :description
        has_one :image
      end

      class ImageSerializer < Serializer
        attributes :src
      end

      def setup
        @profile = Model.new({
          name: 'Name',
          description: 'Description',
          image: Image.new(src: '/img.jpg')
        })
      end

      def test_has_one_with_namespaced_serializer
        expected = {
          name: 'Name',
          description: 'Description',
          image: {src: '/img.jpg'}
        }

        assert_serialized expected, ProfileSerializer.new(@profile)
      end
    end
  end
end