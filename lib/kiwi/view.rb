class Kiwi::View

  def self.v_attribute name, type, opts={}
    if block_given?
      opts, type = type, nil if Hash === type
      type = Class.new self
      yield type
    end

    name = name.to_s
    v_attributes[name] = Attribute.new name, type, opts
  end


  def self.v_attributes
    @view_attributes ||= {}
  end


  def self.build obj
    new(obj).to_hash
  end


  def initialize obj
    @obj   = obj
    @value = nil
  end


  def to_hash rebuild=false
    return @value if @value && !rebuild

    self.class.v_attributes.each do |name, attrib|
      @value[name.to_s] = attrib.value_from @obj
    end

    @value
  end
end
