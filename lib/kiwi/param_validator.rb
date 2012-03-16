class Kiwi::ParamValidator

  include Kiwi::Validator


  def initialize resource_class
    @resource_class = resource_class
    @validators     = {}
  end


  def validate! mname, params
    mname = mname.to_s
    value = {}

    params.each do |name, value|
      table = @validators[name]

      if !table || table[:except].include?(mname) ||
        !table[:only].empty? && !table[:only].include?(mname)

        raise BadRequest,
          "Invalid param `#{name}': #{mname} #{@resource_class.route}"
      end

      val = table[:attr].value_from params
      value[name.to_s] = val unless val.nil? && table[:attr].optional
    end

    value
  end


  def subvalidator
    self.class.new(@resource_class)
  end


  def assign_attribute attr, opts={}
    @validators[attr.name] = {
      :attr   => attr,
      :only   => Array(opts[:only]),
      :except => Array(opts[:except])
    }
  end
end
