class Kiwi::Param < Kiwi::Validator::Attribute

  attr_reader :except, :only

  def initialize name, type, opts={}
    super
    @only   = Array(opts[:only])
    @except = Array(opts[:except])
  end


  def include? mname
    !@except.include?(mname) &&
      (@only.empty? || @only.include?(mname))
  end
end
