##
# Defines the application and handles requests.

class Kiwi::App

  # Set of default resources included with the app.
  DEFAULT_RESOURCES = [
    [Kiwi::Resource::App,       "/"],
    [Kiwi::Resource::Resource,  "/_resource"],
    [Kiwi::Resource::Link,      "/_link"],
    [Kiwi::Resource::Attribute, "/_attribute"],
    [Kiwi::Resource::Error,     "/_error"],
  ]


  ##
  # Clone resource list when inheriting.

  def self.inherited subclass
    subclass.routes.concat self.routes
  end


  def self.init # :nodoc:
    DEFAULT_RESOURCES.each do |(rsc_klass, path)|
      resource rsc_klass, path
    end
  end


  ##
  # Read or set the name of this app's api. Used as the media-subtype.
  # May also be used for api versionning:
  #   api_name "vnc.company.myapp.v1"
  #
  # Defaults to `vnc.kiwi.[app_name]'

  def self.api_name name=nil
    @api_name ||= "vnc.kiwi.#{self.name}"
    @api_name   = name if name
    @api_name
  end


  ##
  # Enforces an exact match on the Accept header or not; defaults to true.
  # When set to false, will accept wildcards in the kiwi.mime env value.

  def self.force_mime_type val=nil
    @force_mime_type = !!val unless val.nil?
    @force_mime_type = true if @force_mime_type.nil?
    @force_mime_type
  end


  ##
  # Assign one or more response formats: json, xml, plist, html.

  def self.formats *f
    @formats   = f unless f.empty?
    @formats ||= [:json]
    @formats
  end


  ##
  # Map a request to a Resource method name. Use only for routing to methods
  # that may not be supported by the client. This explicit method of routing
  # also lets Resources know how to build links for methods unsupported by
  # the client.
  #
  #   # Route post requests with a path ending in "/update" to Resource#put
  #   map_request [:post, ':route/update'], :put
  #
  #   # Route post requests with a :_method param set to 'put' to Resource#put
  #   map_request [:post, {:_method => 'put'}], :put
  #
  # Note: Only one mapping per Resource method name is supported.

  def self.map_request conditions, mname
    omethod = opath = oparams = nil

    conditions.each do |c|
      case c
      when Symbol then omethod = c
      when String then opath   = c
      when Hash   then oparams = c
      end
    end

    request_maps[mname] =
      {:method => omethod, :path => opath, :params => oparams}
  end


  ##
  # The first part of the mime_type. Defaults to 'application'.
  # Typical values are 'application' or 'text'.

  def self.media_type mtype=nil
    @media_type ||= 'application'
    @media_type   = mtype if mtype
    @media_type
  end


  ##
  # Returns all the supported mime types for this App class.

  def self.mime_types *more
    (@custom_mime_types ||= []).concat more
    @custom_mime_types |
      self.formats.map{|f| "#{media_type}/#{api_name}+#{f}" }
  end


  ##
  # Accessor for explicit request map routing. See App.map_request.

  def self.request_maps
    @req_maps ||= {}
  end


  ##
  # Accessor for all resources attributed to this App class.

  def self.resources
    routes.map{|r| r[1] }
  end


  ##
  # Returns a Hash of Kiwi::Route instances to Kiwi::Resource classes.

  def self.routes
    @routes ||= []
  end


  ##
  # Assign a Resource to this App class and assign a path.
  # Path defaults to the underscored version of the Resource class name.
  #   resource FooResource
  #   #=> "/foo_resource"
  #
  #   resource FooResource, "/foo/bar"
  #   #=> "/foo/bar"

  def self.resource rsc_klass, path=nil
    raise ArgumentError, "Kiwi::Resource class must be given" unless
      rsc_klass.ancestors.include? Kiwi::Resource

    path ||= rsc_klass.name.gsub(/([A-Za-z0-9])([A-Z])/,'\1_\2').downcase

    route = Kiwi::Route.new(path)
    routes.unshift [route, rsc_klass]

    path
  end


  extend Kiwi::Hooks


  attr_accessor :env, :headers

  def initialize
    @headers = {}
    @env     = nil
  end


  ##
  # Returns true if this app can return the given content type.

  def accept? ctype
    unless self.class.force_mime_type
      ctype = Regexp.escape ctype
      ctype = ctype.gsub("\\*", "[^/]*")
      matcher = %r{#{ctype}}
    end

    !!self.class.mime_types.find do |mt|
      if matcher
        mt =~ matcher
      else
        mt == ctype
      end
    end
  end


  ##
  # Shortcut for self.class.api_name.

  def api_name
    self.class.api_name
  end


  ##
  # Shortcut for self.class.api_name.

  def mime_types
    self.class.mime_types
  end


  ##
  # Shortcur for self.class.request_maps.

  def request_maps
    self.class.request_maps
  end


  ##
  # Shortcut for self.class.resources.

  def resources
    self.class.resources
  end


  ##
  # Rack-compliant call method.

  def call env
    self.dup.dispatch! env
  end


  ##
  # Handle the request.

  def dispatch! env
    @env = env
    setup_env

    trigger :before

    validate_env!

    render call_resource

  rescue => err
    @env['kiwi.error'] = err

    if err.respond_to?(:status)
      status err.status
      trigger err.status, err
    else
      status 500 # TODO: Default Status
      trigger err.class, err
    end

    # TODO: Only use backtrace if not in prod mode
    render Kiwi::Resource::Error.build(err.to_hash)
  end


  ##
  # Call post triggers and output the response.

  def render res_data
    trigger :postprocess, res_data

    body = @env['kiwi.serializer'].call res_data
    trigger :after, body

    content_type
    @headers['Content-Length'] = body.bytesize if body.respond_to?(:bytesize)

    [status, @headers, [body]]
  end


  ##
  # Set or get the content type for the response.
  # Assinging content_type is discouraged as it defaults to the
  # `Accept' header sent with the request.

  def content_type ctype=nil
    @headers['Content-Type']   = ctype if ctype
    @headers['Content-Type'] ||=
      "#{self.class.media_type}/#{self.class.api_name}+#{@env['kiwi.format']}"

    @headers['Content-Type']
  end


  ##
  # Set or get the response status code.

  def status st=nil
    @status   = st if st
    @status ||= 200 #TODO: replace with constants or Kiwi.status[:OK]
  end


  ##
  # Find a resource from its string representation.

  def find_resource str
    resources.find{|rsc_klass| rsc_klass.to_s == str }
  end


  ##
  # Get the link for the given resource and method.

  def link_for rsc_klass, mname, id=nil
    mname = mname.to_sym

    raise Kiwi::MethodNotAllowed,
      "Method not supported `#{mname}' for #{rsc_klass.name}" unless
        rsc_klass.resource_methods.include?(mname) || rsc_klass.reroutes[mname]

    href       = route_for(rsc_klass).path.dup
    rsc_method = mname
    map        = request_maps[mname]

    if map
      rsc_method = map[:method] || Kiwi.default_http_verb
      href       = map[:path].sub(":route", href) if map[:path]
    end

    href << "#{Kiwi::Route.delimiter}#{id || rsc_klass.identifier.inspect}" if
      rsc_klass.id_resource_methods.include?(mname)

    href << "?" << Kiwi::Link.build_query(map[:params]) if map && map[:params]

    Kiwi::Link.new rsc_method, href, rsc_klass.params_for_method(mname)
  end


  ##
  # Single link to a specific resource and method. Raises a ValidationError
  # if not all required params are provided.

  def link_to rsc_klass, mname, params=nil
    link_for(rsc_klass, mname).build(params)
  end


  ##
  # Get the Route instance for a given Resource class.

  def route_for rsc_klass
    Array(self.class.routes.find{|(route, rsc)| rsc == rsc_klass })[0]
  end


  ##
  # Get a Resource class for a given path String.

  def resource_for path
    Array(self.class.routes.find{|(route, rsc)| route.routes? path })[1]
  end


  ##
  # Trigger any application hook.

  def trigger hook, *args
    return unless self.class.hooks[hook]
    self.class.hooks[hook].each do |block|
      instance_exec(*args, &block)
    end
  end


  private

  ##
  # Setup the environment from the request env.

  def setup_env
    @env['kiwi.app']    = self
    @env['kiwi.mime']   = @env['HTTP_ACCEPT']
    @env['kiwi.path']   = @env['PATH_INFO']
    @env['kiwi.method'] = @env['REQUEST_METHOD'].downcase.to_sym
    @env['kiwi.params'] = ::Rack::Request.new(@env).params
    @env['kiwi.format']     ||= @env['kiwi.mime'].to_s.sub(%r{^\w+/\w+\+?}, '')
    @env['kiwi.serializer'] ||= Kiwi.serializers[@env['kiwi.format'].to_sym]

    id_route, id_rsc = nil

    self.class.routes.each do |(route, rsc)|
      if route.routes? @env['kiwi.path']
        @env['kiwi.route']    = route
        @env['kiwi.resource'] = rsc
        break

      elsif route.routes_with_id? @env['kiwi.path']
        id_route ||= route
        id_rsc   ||= rsc
      end
    end

    @env['kiwi.route']    ||= id_route
    @env['kiwi.resource'] ||= id_rsc
  end


  ##
  # Ensure we have a valid requested mime-type and resource path.
  # Raises Kiwi::NotAcceptable if mime-type is invalid.
  # Raises Kiwi::ResourceNotFound if path could not be matched to a resource.

  def validate_env!
    raise Kiwi::NotAcceptable,
      "Invalid request format `#{@env['kiwi.mime']}'" unless
        accept?(@env['kiwi.mime'])

    raise Kiwi::ResourceNotFound,
      "No resource for `#{@env['kiwi.path']}'" unless @env['kiwi.resource']
  end


  ##
  # Make the call to the resource.

  def call_resource
p @env['kiwi.resource']
p @env['kiwi.route'].parse(@env['kiwi.path'])
    @env['kiwi.params'].merge! @env['kiwi.route'].parse(@env['kiwi.path'])

    @env['kiwi.resource'].new(self).
      call(@env['kiwi.method'], @env['kiwi.params'])
  end


  init
end
