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
  # Takes care of assignment only. May be overridden in child includer.

  def self.assign_attribute attr, opts
    v_attributes[attr.name] = attr
  end


  ##
  # Returns a hash of name/attr pairs for all validator attributes.

  def self.v_attributes
    @validator_attributes ||= {}
  end


  ##
  # Build the validator from an object or hash.

  def self.build obj
    value = {}

    v_attributes.each do |name, attrib|
      val = attrib.value_from obj
      value[name.to_s] = val unless val.nil? && attrib.optional
    end

    value
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
