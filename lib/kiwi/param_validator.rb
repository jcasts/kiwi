class Kiwi::ParamValidator

  include Kiwi::Validator


  def initialize resource_class
    @resource_class   = resource_class
    @global_validator = Class.new Kiwi::Validator
    @method_validator = {}
  end


  def validate! mname, params
  end


  def subvalidator
    self.class.new(@resource_class)
  end


  def v_attributes mname
    
  end


  def assign_attribute name, type, opts={}
    
  end
end
