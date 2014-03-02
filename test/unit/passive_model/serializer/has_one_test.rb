require 'test_helper'

module PassiveModel
  class Serializer
    class HasOneTest < Test
      class ProfileSerializer < Serializer
        attributes :name, :description
        has_one :image
      end

      class ImageSerializer < Serializer
        attributes :src
      end

      class PictureSerializer < Serializer
        attributes :src
      end

      class FullImageSerializer < Serializer
        attributes :src, :width, :height
      end

      module DelegateMixin
        def serializer_for(assoc_object, serializer, type, assoc, options)
          FullImageSerializer
        end
      end

      class ProfileSerializerWithPicture < Serializer
        attributes :name, :description
        has_one :picture
      end

      class ProfileSerializerWithInlineOption < Serializer
        attributes :name, :description
        has_one :image, serializer: FullImageSerializer
      end

      class ProfileSerializerWithLocalSerializer < ProfileSerializer
        ImageSerializer = FullImageSerializer
      end

      class ProfileSerializerWithLocalHook < ProfileSerializer
        include DelegateMixin
      end

      class Delegate
        extend DelegateMixin
      end

      class NullDelegate
        def self.serializer_for(assoc_object, serializer, type, assoc, options)
          nil
        end
      end

      def setup
        @profile = Model.new({
          name: 'Name',
          description: 'Description',
          image: Model.new(src: '/img.jpg', width: 50, height: 50),
          picture: Model.new(src: '/img.jpg', width: 50, height: 50)
        })

        @expected = {
          name: 'Name',
          description: 'Description',
          image: {src: '/img.jpg'}
        }

        @expected_full = {
          name: 'Name',
          description: 'Description',
          image: {src: '/img.jpg', width: 50, height: 50}
        }

        # Setup the global ImageSerializer and PictureSerializer constants
        Object.const_set :ImageSerializer, ImageSerializer
        Object.const_set :PictureSerializer, PictureSerializer
      end

      def teardown
        # Remove the global ImageSerializer constant
        Object.send :remove_const, :ImageSerializer
        Object.send :remove_const, :PictureSerializer
      end

      def test_has_one_with_global_serializer
        assert_serialized @expected, ProfileSerializer.new(@profile)
      end

      def test_has_one_with_local_serializer
        assert_serialized @expected_full, ProfileSerializerWithLocalSerializer.new(@profile)
      end

      def test_has_one_with_different_name
        expected = {
          name: 'Name',
          description: 'Description',
          picture: {src: '/img.jpg'}
        }

        assert_serialized expected, ProfileSerializerWithPicture.new(@profile)
      end

      def test_has_one_with_inline_option
        assert_serialized @expected_full, ProfileSerializerWithInlineOption.new(@profile)
        assert_serialized @expected_full, ProfileSerializerWithInlineOption.new(@profile, delegate: Delegate)
      end

      def test_has_one_with_local_hook
        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile)
        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile, delegate: NullDelegate)
      end

      def test_has_one_with_delegate
        assert_serialized @expected_full, ProfileSerializer.new(@profile, delegate: Delegate)
        assert_serialized @expected_full, ProfileSerializer.new(@profile, delegates: Delegate)
      end

      def test_has_one_delegates_chain
        assert_serialized @expected, ProfileSerializer.new(@profile, delegate: [NullDelegate])
        assert_serialized @expected, ProfileSerializer.new(@profile, delegates: [NullDelegate])

        assert_serialized @expected_full, ProfileSerializer.new(@profile, delegate: [NullDelegate, Delegate])
        assert_serialized @expected_full, ProfileSerializer.new(@profile, delegates: [NullDelegate, Delegate])

        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile, delegate: [NullDelegate])
        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile, delegates: [NullDelegate])
      end
    end
  end
end