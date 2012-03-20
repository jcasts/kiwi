
class Kiwi::Resource

  def self.inherited subclass
    unless subclass.route
      new_route = subclass.name.gsub("::", Kiwi.route_delim)
      new_route = new_route.gsub(/([A-Z0-9])([A-Z])/,'\1_\2').downcase
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

    elsif !param[field]
      param.string field,
        :desc => "Id of the resource",
        :only => id_resource_methods
    end

    @identifier = field
  end


  ##
  # Array of links for this resource.

  def self.links_for id
    links = []
    resource_methods.each do |mname|
      link = link_for mname, id
      links << link if link
    end
  end


  ##
  # Single link for this resource, for a method and id.

  def self.link_for mname, id
    id  ||= identifier.inspect
    mname = mname.to_sym
    return unless public_instance_methods.include? mname

    href  = route.dup

    unless Kiwi.http_verbs.include?(mname)
      http_method = :get
      href << ".#{mname}"
    end

    href << "#{Kiwi.route_delim}#{id}" if id_resource_methods.include?(mname)

    {
      :href   => href,
      :method => http_method.to_s.upcase,
      :params => param.for_method(mname) # TODO: implement to_hash
    }
  end


  ##
  # The param description and validator accessor.

  def self.param &block
    @param ||= Kiwi::ParamValidator.new(self)
    @param.instance_eval &block if block_given?
    @param
  end


  ##
  # The list of methods to return as resource links if
  # defined as instance methods.

  def self.resource_methods
    @resource_methods ||=
      [:get, :put, :patch, :delete, :post, :list, :options]
  end


  ##
  # The expected type of response and request method for each resource_method.

  def self.id_resource_methods
    @id_resource_methods ||= [:get, :put, :patch, :delete]
  end


  ##
  # The route to access this resource. Defaults to the underscored version
  # of the class name.

  def self.route *parts
    return @route if parts.empty?
    string = parts.join Kiwi.route_delim
    delim  = Regexp.escape Kiwi.route_delim
    @route = string.sub(/^(#{delim})?/, Kiwi.route_delim).
                    sub(/(#{delim})?$/, "")
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
    preview ? preview.build(data) : data
  end


  ##
  # Create a resource view from the given data.

  def self.view_from data
    view ? view.build(data) : data
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

    if Array === data
      data = data.map do |item|
        add_links self.class.view_from(item)
      end

    else
      data = add_links self.class.view_from(data)
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
    # TODO: redirect to a Kiwi::LinkResource#get id=Foo ?
    # redirect :list, Kiwi::Resource::Link, :resource => self
    self.class.links_for @params[self.class.identifier]
  end


  private

  def add_links data
    data['links'] ||=
      Kiwi::Resource::Link.view.build \
        self.class.links_for(data[self.class.identifier.to_s])

    data
  end
end
