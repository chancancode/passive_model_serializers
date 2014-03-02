require 'test_helper'

module PassiveModel
  class Serializer
    class CompatibilityTest < Test
      class Image < Model
      end

      class ProfileSerializer < ActiveModel::Serializer
        attributes :name, :description
        has_one :image
      end

      class ProfileSerializerWithPicture < ActiveModel::Serializer
        attributes :name, :description
        has_one :picture
      end

      class ImageSerializer < ActiveModel::Serializer
        attributes :src
      end

      def setup
        @profile = Model.new({
          name: 'Name',
          description: 'Description',
          image: Image.new(src: '/img.jpg'),
          picture: Image.new(src: '/img.jpg')
        })
      end

      def test_has_one
        expected = {
          name: 'Name',
          description: 'Description',
          image: {src: '/img.jpg'}
        }

        assert_serialized expected, ProfileSerializer.new(@profile)
      end

      def test_has_one_with_different_name
        expected = {
          name: 'Name',
          description: 'Description',
          picture: {src: '/img.jpg'}
        }

        assert_serialized expected, ProfileSerializerWithPicture.new(@profile)
      end
    end
  end
end