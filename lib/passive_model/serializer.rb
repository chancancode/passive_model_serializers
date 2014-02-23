module PassiveModel
  class Serializer
    class << self
      attr_accessor :_attributes

      def inherited(base)
        base._attributes = (_attributes || []).dup
      end

      def attributes(*attrs)
        _attributes.concat attrs

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.read_attribute_for_serialization attr
            end
          end
        end
      end
    end

    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def attributes
      self.class._attributes.dup.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def serializable_hash(options = nil)
      attributes
    end 
  end
end