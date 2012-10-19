class Kiwi::Param < Kiwi::Attribute

  attr_reader :except, :only

  def initialize name, type, opts={}
    super
    @only   = Array(opts[:only])
    @except = Array(opts[:except])
  end


  ##
  # Coerce a String into the expected param type if necessary.

  def coerce str
    return str if Kiwi::Validator === self.type || self.type === str

    str  = str.to_s.strip
    rule = Kiwi.input_types[self.type]
    raise TypeError, "Can't coerce #{str.class} into #{self.type}" unless rule

    rule.respond_to?(:call) ? rule.call(str) : str.__send__(rule)
  end


  ##
  # Check if the given method name is allowed based on except and only rules.

  def include? mname
    !@except.include?(mname) &&
      (@only.empty? || @only.include?(mname))
  end


  private

  def validate val, skip_collection=false
    return super if @collection && !skip_collection
    super coerce(val), skip_collection
  end
end
