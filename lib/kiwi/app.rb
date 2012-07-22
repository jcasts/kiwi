##
# Defines the application and handles requests.

class Kiwi::App

  ##
  # Clone resource list when inheriting.

  def self.inherited subclass
    subclass.resources.concat self.default_resources
    subclass.resources.concat self.resources
    subclass.resources.uniq!
  end


  ##
  # Set of default resources included with the app.

  def self.default_resources
    [Kiwi::Resource::Resource, Kiwi::Resource::Link,
      Kiwi::Resource::App, Kiwi::Resource::Attribute, Kiwi::Resource::Error]
  end


  ##
  # Read or set the name of this app's api.
  # Used for api versionning:
  #  api_name "company.myapp.v1"

  def self.api_name name=nil
    @api_name ||= self.name
    @api_name   = name if name
    @api_name
  end


  ##
  # Enforces an exact match on the Accept header or not, defaults to
  # Kiwi.force_accept_header. When set to false, will accept wildcards
  # in the HTTP_ACCEPT env value.

  def self.force_accept_header val=nil
    @force_accept_header = !!val unless val.nil?
    @force_accept_header.nil? ? Kiwi.force_accept_header : @force_accept_header
  end


  ##
  # Assign one or more response formats: json, xml, plist, html.

  def self.formats *f
    @formats   = f unless f.empty?
    @formats ||= [:json]
    @formats
  end


  ##
  # The first part of the mime_type. Defaults to 'application'.

  def self.media_type mtype=nil
    @media_type ||= 'application'
    @media_type   = mtype if mtype
    @media_type
  end


  ##
  # Returns all the supported mime types.

  def self.mime_types *more
    (@custom_mime_types ||= []).concat more
    @custom_mime_types |
      self.formats.map{|f| "#{media_type}/#{api_name}+#{f}" }
  end


  ##
  # Accessor for all resources.

  def self.resources
    @resources ||= []
  end


  ##
  # Define a single resource path.

  def self.resource rsc_klass
    raise ArgumentError, "Kiwi::Resource class must be given" unless
      rsc_klass.ancestors.include? Kiwi::Resource

    self.resources << rsc_klass
  end


  extend Kiwi::Hooks


  attr_accessor :env, :request, :response

  def initialize
    @response  = nil
    @request   = nil
    @env       = nil
  end


  ##
  # Returns true if this app can return the given content type.

  def accept? ctype
    unless self.class.force_accept_header
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
  # Rack-compliant call method.

  def call env
    app = self.dup
    app.dispatch! env
  end


  ##
  # Make handle the request.

  def dispatch! env
    raise Kiwi::NotAcceptable,
      "Accept header `#{env['HTTP_ACCEPT']}' invalid" unless
        accept?(env['HTTP_ACCEPT'])

    env['kiwi.resource'] =
      self.class.resources.find{|rsc| rsc.routes? env['PATH_INFO']}

    # TODO: Set serializer here
    # env['kiwi.serializer']

    trigger :before, env

    raise Kiwi::RouteNotFound,
      "No resource for `#{env['PATH_INFO']}'" unless env['kiwi.resource']

    rsc = env['kiwi.resource'].new(self)

    rsc_method = env['REQUEST_METHOD'].downcase.to_sym
    rsc_path   = env['PATH_INFO']
    rsc_params = Rack::Request.new env

    res_data = rsc.call(rsc_method, rsc_path, rsc_params)

    # TODO: Catch and build error resources from exceptions
    # TODO: Make serializer!
    body = env['kiwi.serializer'].call res_data
    resp = [200, {'Content-Type' => self.content_type}, body]
    trigger :after, resp

    resp
  end


  ##
  # Fully formed content type.

  def content_type
    return unless @env
    "#{self.class.media_type}/#{self.class.api_name}+#{format}"
  end


  ##
  # Find a resource from its string representation.

  def find_resource str
    rsc = Kiwi.find_const str
    return rsc if resources.include?(rsc)
  end


  ##
  # Returns the format requested by the client.

  def format
    return unless @env
    f = env['HTTP_ACCEPT'].to_s.sub(%r{^\w+/\w+\+?}, '')
    f.empty? ? self.class.formats.first : f.to_sym
  end


  ##
  # Trigger any application hook.

  def trigger hook, *args
    return unless self.class.hooks[hook]
    instance_exec(*args, &self.class.hooks[hook])
  end


  ##
  # Shortcut for self.class.resources.

  def resources
    self.class.resources
  end
end
