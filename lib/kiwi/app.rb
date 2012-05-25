##
# Defines the application and handles requests.

class Kiwi::App

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
  # The error view to output errors as. Defaults to Kiwi::View::Error.

  def self.error err_view=nil
    @err_view ||= Kiwi::View::Error
    @err_view   = err_view if err_view
    @err_view
  end


  ##
  # Enforces an exact match on the Accept header or not, defaults to
  # Kiwi.force_accept_header. When set to false, will accept wildcards
  # in the HTTP_ACCEPT env value.

  def self.force_accept_header val=nil
    @force_accept_header = !!val unless val.nil?
    @force_accept_header = Kiwi.force_accept_header if @force_accept_header.nil?
    @force_accept_header
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

  def self.mime_types
    self.formats.map{|f| "#{media_type}/#{api_name}+#{f}" }
  end


  ##
  # Accessor for all resources.

  def self.resources
    @resources ||= []
  end


  ##
  # Define a single resource path.

  def self.resource resource_klass
    raise ArgumentError, "Kiwi::Resource class must be given" unless
      resource_klass.ancestors.include? Kiwi::Resource

    self.resources << resource_klass
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
  # Rack-compliant call method.

  def call env
    raise Kiwi::NotAcceptable,
      "Accept header `#{env['HTTP_ACCEPT']}' invalid" unless
        accept?(env['HTTP_ACCEPT'])

    rsc_klass = self.class.resources.find{|rsc| rsc.routes? env['PATH_INFO']}

    raise Kiwi::RouteNotFound,
      "No resource for `#{env['PATH_INFO']}'" unless rsc_klass

    app = self.clone env

    rsc_klass.new(app).
      call env['REQUEST_METHOD'].downcase.to_sym, app.params

    app.response

  rescue => e
    self.class.error.build e
  end


  ##
  # Clone the app instance and assign instance variables based on env.

  def clone env
    app = self.dup

    app.env      = env
    app.request  = Rack::Request.new env
    app.response = [200, {'Content-Type' => content_type }, ['']]

    app
  end


  ##
  # Fully formed content type.

  def content_type
    return unless @env
    "#{self.class.media_type}/#{self.class.api_name}+#{format}"
  end


  ##
  # Returns the format requested by the client.

  def format
    return unless @env
    f = env['Accept'].to_s.sub(%r{^\w+/\w+\+?}, '')
    f.empty? ? self.class.formats.first : f.to_sym
  end


  ##
  # Sugar for request.params

  def params
    return {} unless @request
    @request.params
  end


  ##
  # Assign the status code of the response.

  def status num
    @response[0] = num
  end


  ##
  # Assign the response headers.

  def headers hash
    @response[1].merge! hash
  end


  ##
  # Trigger any application hook.

  def trigger hook, *args
    return unless self.class.hooks[hook]
    instance_exec(*args, &self.class.hooks[hook])
  end
end
