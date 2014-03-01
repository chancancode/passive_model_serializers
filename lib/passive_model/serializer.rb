require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'

module PassiveModel
  class Serializer
    class << self
      attr_accessor :_attributes

      def inherited(base)
        base._attributes = (_attributes || {}).dup
      end

      def attributes(*attrs)
        attrs.each do |attr|
          _attributes[attr] = attr

          unless method_defined?(attr)
            define_method attr do
              object.read_attribute_for_serialization attr
            end
          end
        end
      end

      def has_one(assoc, **options)
        # This defines...
        #   def user
        #     object.user
        #   end

        unless method_defined?(assoc)
          define_method assoc do
            object.send assoc
          end   
        end

        # This defines...
        #   def _user
        #     @_user ||= begin
        #       if u = user
        #         build_serializer(u, :has_one, :user)
        #       end
        #     end
        #   end

        _assoc = :"_#{assoc}"
        _assoc_ivar = :"@_#{assoc}"

        define_method _assoc do
          if instance_variable_defined?(_assoc_ivar)
            instance_variable_get(_assoc_ivar)
          else
            cached = begin
              if associated = send(assoc)
                build_serializer(associated, :has_one, assoc, options)
              end
            end

            instance_variable_set(_assoc_ivar, cached)
          end
        end

        # This defines...
        #   def _serializable_user
        #     _user.try(:serializable_hash)
        #   end

        define_method :"_serializable_#{assoc}" do
          send(_assoc).try(:serializable_hash)
        end

        _attributes[assoc] = :"_serializable_#{assoc}"
      end
    end

    attr_accessor :object

    def initialize(object, **options)
      @object = object
      @delegate = options.delete(:delegate)
      @options = options
    end

    def attributes
      self.class._attributes.dup.each_with_object({}) do |(name, meth), hash|
        hash[name] = send(meth)
      end
    end

    def serializable_hash(options = nil)
      attributes
    end

    protected
      def serializer_for(assoc_object, serializer, type, assoc, options)
        if type == :has_one
          self.class.const_get("#{assoc.to_s.classify}Serializer")
        end
      end

    private
      def build_serializer(assoc_object, type, assoc, options)
        serializer = options[:serializer] ||
          @delegate.try(:serializer_for, assoc_object, self, type, assoc, options) ||
          self.serializer_for(assoc_object, self, type, assoc, options)

        serializer.new(assoc_object)
      end
  end
end