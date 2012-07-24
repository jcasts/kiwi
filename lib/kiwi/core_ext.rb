unless defined?(Boolean)
  module Boolean; end
  TrueClass.send :include, Boolean
  FalseClass.send :include, Boolean
end

class Exception
unless instance_methods.include?(:to_hash)
  def to_hash
    hash = {
      # TODO: replace 500 with Kiwi.status[:INTERNAL_ERROR]
      :status => (respond_to?(:status) ? status : 500),
      :error  => self.class.name
    }
    hash[:backtrace] = self.backtrace if self.backtrace

    hash
  end
end
end
