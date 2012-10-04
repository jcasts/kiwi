##
# Defines the application and handles requests.

class Kiwi::App

  # Set of default resources included with the app.
  DEFAULT_RESOURCES = [
    [Kiwi::Resource::App,       "/"],
    [Kiwi::Resource::Resource,  "/_resource/?:id"],
    [Kiwi::Resource::Link,      "/_link/?:id"],
    [Kiwi::Resource::Attribute, "/_attribute"],
    [Kiwi::Resource::Error,     "/_error"],
  ]

  # Mapping of status codes. Defaults to HTTP status codes.
  STATUS_CODES = {
    'OK'                  => 200,
    'Created'             => 201,
    'Accepted'            => 202,
    'NoContent'           => 204,
    'Moved'               => 301,
    'Found'               => 302,
    'SeeOther'            => 303,
    'NotModified'         => 304,
    'TemporaryRedirect'   => 307,
    'BadRequest'          => 400,
    'Unauthorized'        => 401,
    'Forbidden'           => 403,
    'NotFound'            => 404,
    'MethodNotAllowed'    => 405,
    'NotAcceptable'       => 406,
    'InternalServerError' => 500,
    'NotImplemented'      => 501,
    'BadGateway'          => 502,
    'ServiceUnavailable'  => 503,
    'GatewayTimeout'      => 504
  }


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
  # Turn debug on or off.
  #   debug true
  #   debug #=> true
  #   debug false
  #   debug #=> false

  def self.debug active=nil
    @debug = false  if @debug.nil?
    @debug = active if !active.nil?
    @debug
  end


  ##
  # Base path for the app. All routes will be built under this prefix path.

  def self.route_prefix path=nil
    @route_prefix = Kiwi::Route.strip(path) if path
    @route_prefix
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
  #   #=> "/foo_resource/?:id"
  #
  #   resource FooResource, "/foo/bar"
  #   #=> "/foo/bar/?:id"

  def self.resource rsc_klass, path=nil
    raise ArgumentError, "Kiwi::Resource class must be given" unless
      rsc_klass.ancestors.include? Kiwi::Resource

    if !path
      path = rsc_klass.name.
              gsub(/([A-Za-z0-9])([A-Z])/,'\1_\2').downcase + "/?:id"
    end

    route = Kiwi::Route.new(path)
    routes << [route, rsc_klass]

    path
  end


  extend Kiwi::Hooks


  attr_accessor :env, :headers

  def initialize environment="development"
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
    h_err = err.to_hash(self.class.debug)
    h_err[:status] = STATUS_CODES[h_err[:status]] ||
                     STATUS_CODES['InternalServerError']

    status h_err[:status]

    trigger err.class,      err
    trigger h_err[:status], err

    setup_mime self.class.mime_types.first unless accept?(@env['kiwi.mime'])

    render Kiwi::Resource::Error.build(h_err)
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
    @status ||= STATUS_CODES['OK']
  end


  ##
  # Find a resource from its string representation.

  def find_resource str
    resources.find{|rsc_klass| rsc_klass.to_s == str }
  end


  ##
  # Return an Array of links for a given Resource.

  def links_for rsc_klass, id=nil
    links = []

    rsc_klass.resource_methods.each do |mname|
      link = link_for(rsc_klass, mname, id)
      links << link
    end

    links
  end


  ##
  # Get the link for the given resource and method.

  def link_for rsc_klass, mname, id=nil
    mname = mname.to_sym

    return unless rsc_klass.resource_methods.include?(mname) ||
                  rsc_klass.reroutes[mname]

    href = self.class.route_prefix || ""
    href << route_for(rsc_klass).path.dup

    rsc_method = mname
    map        = request_maps[mname]

    if map
      rsc_method = map[:method] || Kiwi.default_http_verb
      href       = map[:path].sub(":route", href) if map[:path]
    end

    href << "?" << Kiwi::Link.build_query(map[:params]) if map && map[:params]

    rel = rsc_klass.reroutes[mname] ?
            rsc_klass.reroutes[mname][:resource] : rsc_klass

    link = Kiwi::Link.new rsc_method, href, rel,
      rsc_klass.params_for_method(mname)

    link.label = rsc_klass.labels[mname]
    link
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
    #TODO: do we need to check for route_prefix here?
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
    @env['kiwi.app'] = self

    setup_mime  @env['HTTP_ACCEPT']
    setup_route @env['REQUEST_METHOD'], @env['PATH_INFO']

    @env['kiwi.params'] = ::Rack::Request.new(@env).params
    @env['kiwi.params'].merge! @env['kiwi.route_params']
  end


  ##
  # Setup the mime type, format, and serializer.

  def setup_mime mime_type
    @env['kiwi.mime']       = mime_type
    @env['kiwi.format']     = @env['kiwi.mime'].to_s.sub(%r{^\w+/\w+\+?}, '')
    @env['kiwi.serializer'] = Kiwi.serializers[@env['kiwi.format'].to_sym]
  end


  ##
  # Setup the route, method, and resource.

  def setup_route mname, path
    @env['kiwi.route_params'] = {}

    if self.class.route_prefix
      return unless path.index(self.class.route_prefix) == 0
      path = path[self.class.route_prefix.length..-1]
    end

    @env['kiwi.path']   = path
    @env['kiwi.method'] = mname.downcase.to_sym

    @env['kiwi.route'], @env['kiwi.resource'] =
      self.class.routes.find do |(route, rsc)|
        params = route.parse(@env['kiwi.path']) and
          @env['kiwi.route_params'] = params
      end
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
      "No resource at path `#{@env['kiwi.path']}'" unless @env['kiwi.resource']
  end


  ##
  # Make the call to the resource.

  def call_resource
    resp = @env['kiwi.resource'].new(self).
      call(@env['kiwi.method'], @env['kiwi.params'])

    raise Kiwi::ResourceNotFound,
      "No resource at path `#{@env['kiwi.path']}'" if resp.nil?

    resp
  end


  init
end
