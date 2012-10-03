class Kiwi::Resource

  def self.inherited subclass
    subclass.init
  end


  def self.init
    reroute :options, Kiwi::Resource::Resource, :get do |params|
      params[Kiwi::Resource::Resource.identifier] = self.class.name
    end

    instance_eval do
      @desc       = nil
      @identifier = nil
      @labels     = {}
      @view       = nil
      @c_label    = nil

      def method_added mname
        return unless resource_methods.include? mname
        @labels[mname] = @c_label
        @c_label = nil
      end
    end
  end


  ##
  # Add a label to the next defined public instance method:
  #   label "Update this resource!"
  #   def put(id)
  #     # do something
  #   end

  def self.label str
    @c_label = str
  end


  ##
  # Returns a mapping of method names to labels.

  def self.labels
    @labels
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
  #   reroute :option, LinkResource, :list do |params|
  #     params.clear
  #     params[:resource] = self.class.route
  #   end
  #
  # If a resource public instance method of the same name is defined,
  # reroute will be ignored in favor of executing the method.

  def self.reroute mname, resource_klass, new_mname=nil, &block
    self.reroutes[mname.to_sym] = {
      :resource => resource_klass,
      :method   => (new_mname || mname).to_sym,
      :proc     => block
    }
  end


  ##
  # Hash list of all reroutes.

  def self.reroutes
    @reroutes ||= {}
  end


  ##
  # Define the view to render for this resource.
  # Used by default on all methods but list.

  def self.view view_class=nil
    return @view unless view_class
    @view = view_class
  end


  ##
  # Create a resource view from the given data.

  def self.view_from data
    view && view.build(data) || data
  end


  ##
  # List of Strings representing the resource class and its ancestors.

  def self.class_list
    @class_list ||=
      self.ancestors[0..self.ancestors.index(Kiwi::Resource)].map(&:to_s)
  end


  ##
  # Build and validate a Resource hash from a data hash.

  def self.build data, opts={}
    data = data.dup
    id = data[self.identifier]      ||
         data[self.identifier.to_s] ||
         opts[self.identifier]

    data[:_class]         ||= self.class_list
    data[self.identifier] ||= id if id

    self.view_from(data)
  end


  ##
  # Create a hash for display purposes.

  def self.to_hash app=nil
    out = {
      :attributes => self.view.to_a,
      :name       => self.name
    }
    out[:desc] = @desc if @desc

    if app
      out[:details] = app.link_for(self, :options).build
      out[:actions] = app.links_for(self).map(&:to_hash)
    end

    out
  end


  ##
  # New Resource instance with the app object that called it.

  def initialize app=nil
    @app          = app
    @params       = {}
  end


  ##
  # Call the resource with a method name and params.

  def call mname, params={}
    return follow_reroute(mname, params) if reroute? mname

    @params, args = validate! mname, params
    data = __send__(mname, *args)

    return unless data

    opts = {self.class.identifier => @params[self.class.identifier]}

    if Array === data
      data = data.map do |item|
        self.class.build item, opts
      end

    else
      data = self.class.build data, opts
    end

    data
  end


  ##
  # Array of links for this Resource.

  def links id=nil
    @app.links_for self, id
  end


  ##
  # Single link for this resource, for a method and id.

  def link_for mname, id=nil
    @app.link_for self.class, mname, id
  end


  ##
  # Single link to a specific resource and method. Raises a ValidationError
  # if not all required params are provided.

  def link_to mname, params=nil
    link_for(mname).build(params)
  end


  ##
  # Validate the incoming request. Returns the validated params hash
  # and the arguments for the method.

  def validate! mname, params
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


  def reroute? mname
    self.class.reroutes[mname] && !resource_methods.include?(mname)
  end


  def follow_reroute mname, params={}
    rdir = self.class.reroutes[mname]
    instance_exec(params, &rdir[:proc]) if rdir[:proc]

    rdir[:resource].new(@app).call rdir[:method], params
  end


  identifier :id
  require 'kiwi/resource/resource'
  init
end
