class Kiwi::ParamSet

  include Kiwi::Validator

  attr_reader :params

  def initialize
    @params = {}
  end


  def [] key
    @params[key.to_sym]
  end


  def delete key
    @params.delete key.to_sym
  end


  def for_method mname, &block
    @params.values.inject([]) do |out, param|
      out << (block_given? ? yield(param) : param) if param.include?(mname)
      out
    end
  end


  def validate! mname, params
    mname = mname.to_sym
    value =
      Hash.new{|h,k| h[k] = h[k.to_sym] if String === k && h.has_key?(k.to_sym)}

    params.each do |name, pvalue|
      name = name.to_sym

      param = @params[name]

      if !param || !param.include?(mname)
        raise Kiwi::InvalidParam, "Invalid param `#{name}': #{mname}"
      end

      val = param.value_from params
      value[name] = val unless val.nil? && param.optional
    end

    value
  end


  def subvalidator
    self.class.new
  end


  def assign_attribute attr, opts={}
    @params[attr.name] = attr
  end


  def new_attribute name, type, opts={}
    Kiwi::Param.new name, type, opts
  end


  def v_attributes
    out = {}
    @params.each{|name, param| out[name] = param }
    out
  end
end
