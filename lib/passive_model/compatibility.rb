module ActiveModel
  class Serializer < PassiveModel::Serializer
    def serializer_for(assoc_object, serializer, type, assoc, options)
      Object.const_get("#{assoc_object.class.name}Serializer")
    end
  end
end