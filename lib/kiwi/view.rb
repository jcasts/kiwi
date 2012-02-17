##
# Describes a view for an endpoint and allows easy attribute
# definition.

class Kiwi::View

  ##
  # Define an Boolean view attribute.

  def self.boolean name, opts={}
    v_attribute name, Boolean, opts
  end


  ##
  # Define a collection of sub-attributes.
  # Will create an anonymous View and yield it to the block.
  #
  #   collection :records, :optional => true do |foo|
  #     foo.integer :score
  #     foo.string  :name
  #   end

  def self.collection name, opts={}, &block
    subset name, {:collection => true}.merge(opts), &block
  end


  ##
  # Define an Integer view attribute.

  def self.integer name, opts={}
    v_attribute name, Integer, opts
  end


  ##
  # Define a String view attribute.

  def self.string name, opts={}
    v_attribute name, String, opts
  end


  ##
  # Define a collection of sub-attributes.
  # Will create an anonymous View and yield it to the block.
  #
  #   subset :address, :optional => true do |addr|
  #     addr.string :zip
  #     addr.string :city
  #     addr.string :street
  #   end

  def self.subset name, opts={}
    v_attribute name, opts do |view_klass|
      yield view_klass
    end
  end


  ##
  # Reference another view.

  def self.view name, klass, opts={}
    v_attribute name, klass, opts
  end


  ##
  # Assign an attribute name with a type
  # Supports any option of Kiwi::View::Attribute.new

  def self.v_attribute name, type, opts={}
    opts, type = type, nil if Hash === type

    if block_given?
      type = Class.new Kiwi::View
      yield type
    end

    name = name.to_s
    v_attributes[name] = Attribute.new name, type, opts
  end


  ##
  # Returns a hash of name/attr pairs for all view attributes.

  def self.v_attributes
    @view_attributes ||= {}
  end


  ##
  # Build the view from an object or hash.

  def self.build obj
    new(obj).to_hash
  end


  ##
  # Create an view instance for a given object or hash.

  def initialize obj
    @obj   = obj
    @value = nil
  end


  ##
  # Build or returned the memoized hash output of the view.

  def to_hash rebuild=false
    return @value if @value && !rebuild

    @value = {}

    self.class.v_attributes.each do |name, attrib|
      val = attrib.value_from @obj
      @value[name.to_s] = val unless val.nil? && attrib.optional
    end

    @value
  end
end
