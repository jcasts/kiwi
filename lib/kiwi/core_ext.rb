unless defined?(Boolean)
  module Boolean; end
  TrueClass.send :include, Boolean
  FalseClass.send :include, Boolean
end


class Object
  def __val_for key
    if respond_to?(:[])
      self[key] || data[key.to_s]
    elsif respond_to?(key)
      __send__(key)
    end
  end
end
