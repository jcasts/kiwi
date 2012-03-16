
class Kiwi::Resource

  def self.inherited subclass
    new_route = subclass.name.split("::").last
    new_route.gsub!(/(.)([A-Z])/,'\1_\2').downcase!
    subclass.route new_route
  end


  ##
  # An optional description for the resource.

  def self.desc string=nil
    return @desc unless string
    @desc = string
  end


  ##
  # The param description and validator accessor.

  def self.param
    @params ||= Class.new Kiwi::Validator
  end


  ##
  # The route to access this resource. Defaults to the underscored version
  # of the class name.

  def self.route string=nil
    return @route unless string
    @route = string.sub(/^\/?/, "/").sub(/\/?$/, "")
  end


  ##
  # Define the view to render for this resource.
  # Used by default on all methods but list.

  def self.view view_class=nil
    return @view unless view_class
    @view = view_class
  end


  ##
  # Define the short version of the view for this resource.
  # Used by default on the list method.

  def self.preview view_class=nil
    return @preview unless view_class
    @preview = view_class
  end
end
