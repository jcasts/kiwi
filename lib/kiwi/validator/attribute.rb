##
# Single attribute node in a validator.
# Handles validation and value retrieval from objects.

class Kiwi::Validator::Attribute

  attr_accessor :name, :collection, :optional, :default, :desc

  ##
  # Create a new attribute with a name and data type.
  # Supported options are:
  # :collection:: Bool - Is this an Array of attributes.
  # :default::    VALUE - The default value to use if none is set.
  # :optional::   Bool - Required or not.

  def initialize name, type, opts={}
    @name        = name.to_s
    @type        = type
    @optional    = !!opts[:optional]
    @collection  = !!opts[:collection]
    @desc        = opts[:desc]

    @has_default = opts.has_key?(:default)
    @default     = opts[:default]

    raise ArgumentError, "Invalid type #{@type.inspect} must be a Class" unless
      Module === @type || String === @type || Kiwi::Validator === @type

    raise Kiwi::InvalidTypeError,
      "Default #{@default.inspect} isn't a #{@type}" if
        @default && Module === @type && !(@type === @default)
  end


  ##
  # Returns a hash that matches a param view description.

  def to_hash
    hash = {:name => @name}

    if Kiwi::Validator === @type
      hash[:attributes] = @type.v_attributes.values.map{|attr| attr.to_hash}
      hash[:type] = '_embedded'
    else
      hash[:type] = @type.to_s
    end

    hash[:desc]       = @desc               if @desc
    hash[:default]    = @default.to_s       if @has_default
    hash[:values]     = @values.map(:to_s)  if @values
    hash[:collection] = @collection         if @collection
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

    elsif Hash === obj && obj.has_key?(@name.to_sym)
      key_found = true
      val = obj[@name.to_sym]

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
        "Collection #{val.inspect} must be an Array" unless Array === val

      return val.map{|v| validate v, true}
    end

    if type
      if Kiwi::Validator === type
       val = type.build val

      elsif type.respond_to?(:ancestors) &&
        type.ancestors.include?(Kiwi::Resource)
        builder = (type.preview || type.view)
        raise Kiwi::ValidationError,
          "Invalid view #{builder.inspect} for resource #{type}" unless
            Kiwi::Validator === builder

        val = builder.build val

      else
        raise Kiwi::InvalidTypeError,
          "#{@name}: #{val.inspect} is not a #{type}" unless type === val
      end
    end

    val
  end
end

