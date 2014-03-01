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

      class FullImageSerializer < Serializer
        attributes :src, :width, :height
      end

      module DelegateMixin
        def serializer_for(assoc_object, serializer, type, assoc, options)
          FullImageSerializer
        end
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
          image: Model.new(src: '/img.jpg', width: 50, height: 50)
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

        # Setup the global ImageSerializer constant
        Object.const_set :ImageSerializer, ImageSerializer
      end

      def teardown
        # Remove the global ImageSerializer constant
        Object.send :remove_const, :ImageSerializer
      end

      def test_has_one_with_global_serializer
        assert_serialized @expected, ProfileSerializer.new(@profile)
      end

      def test_has_one_with_local_serializer
        assert_serialized @expected_full, ProfileSerializerWithLocalSerializer.new(@profile)
      end

      def test_has_one_with_delegate
        assert_serialized @expected_full, ProfileSerializer.new(@profile, delegate: Delegate)
      end

      def test_has_one_with_local_hook
        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile)
      end

      def test_has_one_with_delegate_returning_nil
        assert_serialized @expected, ProfileSerializer.new(@profile, delegate: NullDelegate)
        assert_serialized @expected_full, ProfileSerializerWithLocalHook.new(@profile, delegate: NullDelegate)
      end
    end
  end
end