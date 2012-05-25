class Kiwi::ParamValidator

  include Kiwi::Validator

  attr_reader :params

  def initialize resource_class
    @resource_class = resource_class
    @params         = {}
  end


  def [] key
    @params[key.to_s]
  end


  def for_method mname
    # TODO: refactor!
    @params.values.select do |table|
      !table[:except].include?(mname) &&
        (table[:only].empty? || table[:only].include?(mname))
    end.map{|table| table[:attr] }
  end


  def validate! mname, params
    mname = mname.to_sym
    value =
      Hash.new{|h,k| h[k] = h[k.to_s] if Symbol === k && h.has_key?(k.to_s)}

    params.each do |name, pvalue|
      name = name.to_s

      table = @params[name]

      if !table || table[:except].include?(mname) ||
        !table[:only].empty? && !table[:only].include?(mname)

        raise Kiwi::BadRequest,
          "Invalid param `#{name}': #{mname} #{@resource_class.route}"
      end

      val = table[:attr].value_from params
      value[name] = val unless val.nil? && table[:attr].optional
    end

    value
  end


  def subvalidator
    self.class.new(@resource_class)
  end


  def assign_attribute attr, opts={}
    @params[attr.name] = {
      :attr   => attr,
      :only   => Array(opts[:only]),
      :except => Array(opts[:except])
    }
  end
end
