class Kiwi::Resource

  def self.inherited subclass
    subclass.redirect :options, Kiwi::Resource::Resource, :get do |params|
      params[Kiwi::Resource::Resource.identifier] = self.class.name
    end

    subclass.instance_eval do
      @route      = nil
      @preview    = nil
      @view       = nil
      @identifier = nil
    end
  end


  ##
  # An optional description for the resource.

  def self.desc string=nil
    return @desc unless string
    @desc = string
  end


  ##
  # The field used as the resource id. Defaults to :id.
  # This attribute is inherited by the superclass by default.
  # Setting it to false will re-enable the inheritance.

  def self.identifier field=nil
    @identifier = field.to_sym if field
    @identifier = nil          if field == false

    out =
      @identifier ||
      superclass.respond_to?(:identifier) && superclass.identifier ||
      :id

    out
  end


  class << self
    private
    def default_id_param # :nodoc:
      Kiwi::Param.new self.identifier, String,
        :desc => "Id of the resource"
    end
  end


  ##
  # Array of links for this resource.

  def self.links_for id
    links = []

    resource_methods.each do |mname|
      links << link_for(mname, id, false)
    end

    links
  end


  ##
  # Single link for this resource, for a method and id.

  def self.link_for mname, id, validate=true
    id  ||= identifier.inspect
    mname = mname.to_sym
    return unless !validate || resource_methods.include?(mname) ||
                  self.redirects[mname]

    href = route.path.dup
    http_method = mname

    unless Kiwi.http_verbs.include?(mname)
      http_method = Kiwi.default_http_verb
      href << ".#{mname}"
    end

    href << "#{Kiwi::Route.delimiter}#{id}" if
      id_resource_methods.include?(mname)

    {
      :href   => href,
      :method => http_method.to_s.upcase,
      :params => params_for_method(mname).map(&:to_hash)
    }
  end


  ##
  # The param description and validator accessor.

  def self.param &block
    @param ||= Kiwi::ParamSet.new
    @param.instance_eval(&block) if block_given?
    @param
  end


  ##
  # An array of param validators for the given method.

  def self.params_for_method mname
    params = param.for_method(mname)

    params.unshift default_id_param if !param[self.identifier] &&
                                        id_resource_methods.include?(mname)

    params
  end


  ##
  # The list of methods to return as resource links if
  # defined as instance methods.

  def self.resource_methods
    public_instance_methods - Kiwi::Resource.public_instance_methods
  end


  ##
  # The expected type of response and request method for each resource_method.

  def self.id_resource_methods
    #@id_resource_methods ||= [:get, :put, :patch, :delete]
    resource_methods.select do |mname|
      prm = public_instance_method(mname).parameters[0]

      prm && prm.any?{|name| name.to_s == identifier.to_s } ||
        param.for_method(mname).any?{|attr| attr.name == identifier.to_s }
    end
  end


  ##
  # Reroute a method call to a different resource and not trigger the view
  # validation. Used to implement the OPTION method:
  #   redirect :option, LinkResource, :list do |params|
  #     params.clear
  #     params[:resource] = self.class.route
  #   end
  #
  # If a resource public instance method of the same name is defined,
  # redirect will be ignored in favor of executing the method.

  def self.redirect mname, resource_klass, new_mname=nil, &block
    self.redirects[mname.to_sym] = {
      :resource => resource_klass,
      :method   => (new_mname || mname).to_sym,
      :proc     => block
    }
  end


  ##
  # Hash list of all redirects.

  def self.redirects
    @redirects ||= {}
  end


  ##
  # The route to access this resource. Defaults to the underscored version
  # of the class name. Pass multiple parts as arguments to use the preset
  # Kiwi route delimiter:
  #   MyResource.route "foo", "bar"
  #   #=> "/foo/bar"

  def self.route *parts
    return @route if @route && parts.empty?

    if parts.empty?
      new_route = self.name.gsub(/([A-Za-z0-9])([A-Z])/,'\1_\2').downcase
      parts     = new_route.split("::")
    end

    @route = Kiwi::Route.new(*parts) do |key|
      next if key == Kiwi::Route.tmp_id
      self.param.string key
    end
  end


  ##
  # Check if this resource routes the given path.

  def self.routes? path
    self.route.routes? path
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


  ##
  # Create a hash for display purposes.

  def self.to_hash
    out = {
      :type       => self.name,
      :links      => links_for(nil),
      :attributes => view.to_a
    }
    out[:desc] = @desc if @desc
    out
  end


  ##
  # New Resource instance with the app object that called it.

  def initialize app=nil
    @app          = app
    @append_links = false
  end


  ##
  # Sets flag to add links to the response.

  def append_links
    @append_links = true
  end


  ##
  # Call the resource with a method name and params.

  def call mname, path, params
    params = merge_path_params! path, params
    return follow_redirect(mname, params) if redirect? mname

    @params, args = validate! mname, path, params
    data = __send__(mname, *args)

    return unless data

    if Array === data
      data = data.map do |item|
        resourcify item
      end

    else
      data = resourcify data
    end

    data
  end


  ##
  # Validate the incoming request. Returns the validated params hash
  # and the arguments for the method.

  def validate! mname, path, params
    meth = resource_method mname

    raise Kiwi::MethodNotAllowed,
      "Method not supported `#{mname}' for #{self.class.name}" unless meth

    params = self.class.param.validate! mname, params
    args   = meth.parameters.map{|(_, name)| params[name.to_s]}

    [params, args]

  rescue Kiwi::InvalidParam => e
    raise Kiwi::BadRequest,
      "#{e.message} for #{self.class.name}##{mname}"
  end


  ##
  # Returns a resource method instance. Similar to public_method.

  def resource_method name
    return unless resource_methods.include?(name.to_sym)
    public_method name
  end


  ##
  # Shortcut for self.class.resource_methods.

  def resource_methods
    @resource_methods ||= self.class.resource_methods
  end


  private


  def redirect? mname
    self.class.redirects[mname] && !resource_methods.include?(mname)
  end


  def follow_redirect mname, params={}
    rdir = self.class.redirects[mname]
    instance_exec(params, &rdir[:proc]) if rdir[:proc]

    rdir[:resource].new(@app).call rdir[:method], params
  end


  def resourcify data
    id = data[self.class.identifier]      ||
         data[self.class.identifier.to_s] ||
         @params[self.class.identifier]

    links = self.class.links_for(id)
    data[self.class.identifier.to_s] ||= id

    data['_type']  ||= self.class.name
    data['_links'] ||= links.map do |link|
      Kiwi::Resource::Link.view.build link
    end if @append_links

    data = self.class.view_from data

    data
  end


  ##
  # Merge the params from the path into the params hash.

  def merge_path_params! path, params={}
    path_params = self.class.route.parse(path)

    params[self.class.identifier] = path_params.delete(Kiwi::Route.tmp_id) if
      path_params.has_key?(Kiwi::Route.tmp_id)

    params.merge( path_params )
  end
end
