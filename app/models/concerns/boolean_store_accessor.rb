module BooleanStoreAccessor
  def boolean_store_accessor(*attr_names)
    attr_names.each do |attr_name|
      define_method "#{attr_name}=" do |value|
        super(ActiveModel::Type::Boolean.new.cast(value))
      rescue NoMethodError
        instance_variable_set("@#{attr_name}", ActiveModel::Type::Boolean.new.cast(value))
      end

      define_method attr_name do
        stored_value = begin
                         super()
                       rescue NoMethodError
                         instance_variable_get("@#{attr_name}")
                       end
        ActiveModel::Type::Boolean.new.cast(stored_value)
      end

      define_method "#{attr_name}?" do
        send(attr_name)
      end
    end
  end
end
