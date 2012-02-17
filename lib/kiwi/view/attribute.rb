##
# Single attribute node in a view.
# Handles validation and value retrieval from objects.

class Kiwi::View::Attribute

  attr_reader :name, :type, :collection, :optional, :default

  def initialize name, type, opts={}
    @name        = name.to_s
    @type        = type
    @optional    = !!opts[:optional]
    @collection  = !!opts[:collection]

    @has_default = opts.has_key?(:default)
    @default     = opts[:default]

    raise ArgumentError, "Type #{@type.inspect} must be a Class" unless
      Module === @type

    raise Kiwi::InvalidTypeError,
      "Default #{@default.inspect} isn't a #{@type}" if
        @default && !(@type === @default)
  end


  def value_from obj
    value, found = retrieve_value obj
    value = validate value if found

    value
  end


  def retrieve_value obj
    val = nil
    key_found = false

    if Hash === obj && obj.has_key?(@name)
      key_found = true
      val = obj[@name]

    elsif Hash === obj && obj.has_key?(@name.to_sym)
      key_found = true
      val = obj[@name.to_sym]

    elsif obj.respond_to? @name
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
      raise Kiwi::InvalidTypeError, "Collection must respond to `map'" if
        !val.respond_to?(:map)

      return val.map{|v| validate v, true}
    end

    if @type
      if @type.ancestors.include?(Kiwi::View)
       val = @type.build val

      else
        raise Kiwi::InvalidTypeError, "#{val.inspect} is not a #{@type}" unless
          @type === val
      end
    end

    val
  end
end

