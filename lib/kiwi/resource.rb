
class Kiwi::Resource

  def self.inherited subclass
    unless subclass.route
      new_route = subclass.name.split("::").last
      new_route = new_route.gsub(/(.)([A-Z])/,'\1_\2').downcase
      subclass.route new_route
    end

    subclass.identifier :id unless subclass.identifier
  end


  ##
  # An optional description for the resource.

  def self.desc string=nil
    return @desc unless string
    @desc = string
  end


  ##
  # The field used as the resource id. Defaults to :id.

  def self.identifier field=nil
    return @identifier unless field

    if param[@identifier]
      p_attr = param.params.delete @identifier.to_s
      p_attr[:attr].name = field.to_s
      param.params[field.to_s] = p_attr
    else
      param.string field,
        :desc => "Id of the resource",
        :only => [:get, :put, :patch, :delete]
    end

    @identifier = field
  end


  ##
  # The param description and validator accessor.

  def self.param
    @param ||= Kiwi::ParamValidator.new(self)
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


  ##
  # Create a resource preview from the given data.

  def self.preview_from data
    view_from data, preview
  end


  ##
  # Create a resource view from the given data.

  def self.view_from data, view_klass=view
    out = view_klass ? view_klass.build(data) : data

    id = if data.respond_to?(:[])
           data[identifier] || data[identifier.to_s]
         elsif data.respond_to?(identifier)
           data.__send__(identifier)
         end

    out.merge links_for(id) # TODO: should this be explicit in the view?
  end


  ##
  # Hash of links for this resource.

  def self.links_for id
    # TODO: implement, maybe as customizable view
    # Also figure out if links should be restricted to http verbs
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
        data = data.map{|item| self.class.view_from item }
      else
        data = self.class.view_from data
      end
    end

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
    self.class.links_for @params[self.class.identifier]
  end
end
