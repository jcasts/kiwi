##
# Single attribute node in a validator.
# Handles validation and value retrieval from objects.

class Kiwi::Validator::Attribute

  attr_reader :name, :collection, :optional, :default, :desc, :values

  ##
  # Create a new attribute with a name and data type.
  # Supported options are:
  # :collection:: Bool - Is this an Array of attributes.
  # :default::    VALUE - The default value to use if none is set.
  # :optional::   Bool - Required or not.
  # :values::     Array|Hash - Supported values for this attribute.
  #               Hash must be of form {:label => "", :value => ""}

  def initialize name, type, opts={}
    self.name    = name
    @type        = type
    @optional    = !!opts[:optional]
    @collection  = !!opts[:collection]
    @desc        = opts[:desc]
    @label       = opts[:label]

    @has_default = opts.has_key?(:default)
    @default     = opts[:default]

    @values = nil
    if opts[:values]
      if Hash === opts[:values]
        @values = opts[:values].map{|k, v| {:label => k, :value => v}}
      else
        @values = Array(opts[:values]).map{|v| {:value => v} }
      end
    end

    raise ArgumentError, "Invalid type #{@type.inspect} must be a Class" unless
      Module === @type || String === @type || Kiwi::Validator === @type

    raise Kiwi::InvalidTypeError,
      "Default #{@default.inspect} isn't a #{@type}" if
        @default && Module === @type && !(@type === @default)
  end


  ##
  # Name attribute writer

  def name= val
    @name = val.to_sym
  end


  ##
  # Returns a hash that matches a param view description.

  def to_hash
    hash = {:name => @name.to_s}

    if Kiwi::Validator === self.type
      hash[:attributes] = self.type.v_attributes.values.map{|attr| attr.to_hash}
      hash[:type] = '_embedded'
    else
      hash[:type] = self.type.to_s
    end

    hash[:values] = @values.map do |h|
      h.merge(:value => h[:value].to_s)
    end if @values

    hash[:collection] = @collection         if @collection
    hash[:default]    = @default.to_s       if @has_default
    hash[:desc]       = @desc               if @desc
    hash[:label]      = @label              if @label
    hash[:optional]   = @optional           if @optional
    hash
  end


  ##
  # Retrieve the attribute value from the passed object. If a hash is given,
  # will look for a key with the same name as the attribute, otherwise will
  # try calling a method with the attribute name.

  def value_from obj
    value, found = retrieve_value obj
    value = validate value if found

    value
  end


  ##
  # The class the value should be.

  def type
    @type = Kiwi.find_const @type if String === @type
    @type
  end


  private


  def retrieve_value obj
    val = nil
    key_found = false

    if Hash === obj && obj.has_key?(@name)
      key_found = true
      val = obj[@name]

    elsif Hash === obj && obj.has_key?(@name.to_s)
      key_found = true
      val = obj[@name.to_s]

    elsif !(Hash === obj) && obj.respond_to?(@name)
      key_found = true
      val = obj.send @name

    elsif !@optional && !@has_default
      raise Kiwi::RequiredValueError, "No `#{@name}' in #{obj.inspect}"
    end

    val = @default if @has_default && !key_found

    [val, key_found]
  end


  def validate val, skip_collection=false
    if @collection && !skip_collection
      raise Kiwi::InvalidTypeError,
        "Value #{val.inspect} expected to be an Array" unless Array === val

      return val.map{|v| validate v, true}
    end

    val = validate_type val if type
    validate_value val      if @values

    val
  end


  def validate_type val
    if Kiwi::Validator === type
      val = type.build val

    elsif type.respond_to?(:ancestors) &&
      type.ancestors.include?(Kiwi::Resource)
      val = type.build val

    else
      raise Kiwi::InvalidTypeError,
        "#{@name}: #{val.inspect} is not a #{type}" unless type === val
    end

    val
  end


  def validate_value val
    return true if @values.any?{|h| h[:value] == val}

    raise Kiwi::BadValueError,
      "Value #{val.inspect} must be in #{@values.map{|h| h[:value]}.inspect}"
  end
end
