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
    params = {}

    @params.each do |name, attr|
      next if table[:except].include?(mname) ||
        !table[:only].empty? && !table[:only].include?(mname)

      params[name] = attr
    end

    params
  end


  def validate! mname, params
    mname = mname.to_s
    value = {}

    params.each do |name, value|
      name = name.to_s

      table = @params[name]

      if !table || table[:except].include?(mname) ||
        !table[:only].empty? && !table[:only].include?(mname)

        raise BadRequest,
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
