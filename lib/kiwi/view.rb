##
# Defines a View and validates data before rendering.

class Kiwi::View

  extend Kiwi::Validator

  ##
  # Validates that the attribute follows the built-in link view.

  def self.link name, opts={}
    v_attribute name, "Kiwi::Resource::Link", opts
  end


  ##
  # Reference another resource.

  def self.resource name, klass, opts={}
    v_attribute name, klass, opts
  end


  ##
  # Reference another view.

  def self.view name, klass, opts={}
    v_attribute name, klass, opts
  end


  ##
  # Implemants nesting for Validator methods.

  def self.subvalidator
    Class.new(Kiwi::View)
  end


  ##
  # Takes care of assignment only. May be overridden in child includer.

  def self.assign_attribute attr, opts
    v_attributes[attr.name] = attr
  end


  ##
  # Creates a new attribute object.

  def self.new_attribute name, type, opts={}
    Kiwi::Attribute.new(name, type, opts)
  end


  ##
  # Returns a hash of name/attr pairs for all validator attributes.

  def self.v_attributes
    @validator_attributes ||= {}
  end


  ##
  # Inherit v_attributes when subclassing.

  def self.inherited subclass
    subclass.v_attributes.merge! v_attributes

    subclass.string('_class', :optional => true, :collection => true) unless
      subclass.v_attributes['_class']
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
