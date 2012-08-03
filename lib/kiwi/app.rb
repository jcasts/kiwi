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
  # Kiwi.force_mime_type. When set to false, will accept wildcards
  # in the kiwi.mime env value.

  def self.force_mime_type val=nil
    @force_mime_type = !!val unless val.nil?
    @force_mime_type.nil? ? Kiwi.force_mime_type : @force_mime_type
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
  # Rack-compliant call method.

  def call env
    self.dup.dispatch! env
  end


  ##
  # Make handle the request.

  def dispatch! env
    @env = env
    setup_env

    trigger :before

    validate_env!

    render call_resource

  rescue => err
    @env['kiwi.error'] = err

    trigger err.class, err
    trigger err.status, err if err.respond_to?(:status)

    render Kiwi::Resource::Error.build(err.to_hash)
  end


  ##
  # Call post triggers and output the response.

  def render res_data
    trigger :postprocess, res_data

    body = @env['kiwi.serializer'].call res_data
    trigger :after, body

    [@status, @headers, body]
  end


  ##
  # Set or get the content type for the response.

  def content_type ctype=nil
    @content_type   = ctype if ctype
    @content_type ||=
      "#{self.class.media_type}/#{self.class.api_name}+#{@env['kiwi.format']}"
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
  # Trigger any application hook.

  def trigger hook, *args
    return unless self.class.hooks[hook]
    self.class.hooks[hook].each do |block|
      instance_exec(*args, &block)
    end
  end


  ##
  # Shortcut for self.class.resources.

  def resources
    self.class.resources
  end


  private

  ##
  # Setup the environment from the request env.

  def setup_env
    @env['kiwi.mime']   = @env['HTTP_ACCEPT']
    @env['kiwi.params'] = ::Rack::Request.new(@env).params
    @env['kiwi.path']   = @env['PATH_INFO']
    @env['kiwi.method'] = @env['REQUEST_METHOD'].downcase.to_sym
    @env['kiwi.format']     ||= @env['kiwi.mime'].to_s.sub(%r{^\w+/\w+\+?}, '')
    @env['kiwi.serializer'] ||= Kiwi.serializers[@env['kiwi.format'].to_sym]
    @env['kiwi.resource']   ||=
      self.class.resources.find{|rsc| rsc.routes? @env['kiwi.path']}
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
    @env['kiwi.resource'].new(self).
      call(@env['kiwi.method'], @env['kiwi.path'], @env['kiwi.params'])
  end
end
