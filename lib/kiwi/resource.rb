
class Kiwi::Resource

  def self.inherited subclass
    new_route = subclass.name.split("::").last
    new_route.gsub!(/(.)([A-Z])/,'\1_\2').downcase!
    subclass.route new_route

    param.string :id, :desc => "Id of the resource",
                      :only => [:get, :put, :patch, :delete]
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
    @params ||= Kiwi::ParamValidator.new(self)
  end


  ##
  # The route to access this resource. Defaults to the underscored version
  # of the class name.

  def self.route string=nil
    return @route unless string
    @route = string.sub(/^\/?/, "/").sub(/\/?$/, "")
  end


  ##
  # Define the short version of the view for this resource.
  # Used by default on the list method.

  def self.preview view_class=nil
    return @preview unless view_class
    @preview = view_class
  end


  ##
  # Define the view to render for this resource.
  # Used by default on all methods but list.

  def self.view view_class=nil
    return @view unless view_class
    @view = view_class
  end


  attr_reader :app

  ##
  # Create a new resource instance for the request.

  def initialize app
    @app = app
  end


  ##
  # Call the resource with a method name and params.

  def call mname, params
    @params, args = validate! mname, params
    data = __send__(mname, *args)

    return unless data

    if self.class.view
      if Array === data
        data = data.map{|item| self.class.view.build item }
      else
        data = self.class.view.build data
      end
    end
    # TODO: add resource links

    data
  end


  ##
  # Validate the incoming request. Returns the validated params hash
  # and the arguments for the method.

  def validate! mname, params
    meth   = public_method mname
    params = self.class.param.validate! mname, params
    args   = meth.parameters.map{|(type, name)| params[name.to_s]}

    [params, args]
  end


  ##
  # Pre-implemented options method.

  def options
    links
  end


  ##
  # Hash of links for this resource.

  def links
    # TODO: implement
  end
end
