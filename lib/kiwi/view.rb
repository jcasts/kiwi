##
# Defines a View and validates data before rendering.

class Kiwi::View

  extend Kiwi::Validator

  ##
  # Reference another view.

  def self.view name, klass, opts={}
    v_attribute name, klass, opts
  end


  def self.subvalidator
    Class.new(self)
  end


  ##
  # Create an validator instance for a given object or hash.

  def initialize obj
    @obj   = obj
    @value = nil
  end


  ##
  # Build or returned the memoized hash output of the validator.

  def to_hash rebuild=false
    return @value if @value && !rebuild
    @value = self.class.build(@obj)
  end
end
