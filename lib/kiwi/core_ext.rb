unless defined?(Boolean)
  module Boolean; end
  TrueClass.send :include, Boolean
  FalseClass.send :include, Boolean
end
