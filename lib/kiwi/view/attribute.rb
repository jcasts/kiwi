##
# Single attribute node in a view.
# Handles validation and value retrieval from objects.

class Kiwi::View::Attribute

  def initialize name, type, opts={}
    @name     = name.to_s
    @type     = type
    @optional = opts[:optional]

    @has_default = opts.has_key?(:default)
    @default     = opts[:default]

    raise Kiwi::InvalidTypeError,
      "Default #{@default.inspect} isn't a #{@type}" if
        @default && !(@type === @default)
  end


  def value_from obj
    key_found = false

    val =
      if Hash === obj && obj.has_key?(@name)
        key_found = true
        obj[@name]

      elsif Hash === obj && obj.has_key?(@name.to_sym)
        key_found = true
        obj[@name.to_sym]

      elsif obj.respond_to? @name
        key_found = true
        obj.send @name

      elsif !@optional && !@has_default
        raise Kiwi::RequiredValueError, "No `#{@name}' in #{obj.inspect}"
      end

    val = @default if @has_default && !key_found

    if @type && key_found
      if @type.ancestors.include?(Kiwi::View)
        return @type.build val
      else
        raise Kiwi::InvalidTypeError, "#{val.inspect} is not a #{@type}" unless
          @type === val
      end
    end

    val
  end
end

