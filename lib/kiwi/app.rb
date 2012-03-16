##
# Defines the application and handles requests.

class Kiwi::App


  def self.apps
    @apps ||= []
  end


  def self.descendants
    child_apps = @apps.dup
    @apps.each do |app|
      child_apps.concat  app.descendants
    end
    child_apps
  end


  def self.inherited subclass
    apps << subclass
  end


  ##
  # Read or set the name of this app's api.
  # Used for api versionning:
  #  api_name "company.myapp.v1"

  def self.api_name name=nil
    @api_name ||= self.class.name
    @api_name   = name if name
    @api_name
  end


  ##
  # Accessor for all resources.

  def self.resources
    @resources ||= {}
  end


  ##
  # Define a single resource path.

  def self.resource path, resource_klass, &block
    path = [@curr_path, path].join("/") if @curr_path

    matcher_and_keys = parse_path path
    resources[matcher_and_keys] = resource_klass

    if block_given?
      @curr_path, old_curr_path = path, @curr_path
      instance_eval &block
      @curr_path = old_curr_path
    end

    resource_klass
  end


  ##
  # Parse a path into a matcher with key params.

  def self.parse_path path
    return [path, []] if Regexp === path

    keys = []
    special_chars = %w{. + ( )}

    pattern =
      path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
        case match
        when "*"
          keys << 'splat'
          "(.*?)"
        when *special_chars
          Regexp.escape(match)
        else
          keys << $2[1..-1]
          "([^/?#]+)"
        end
      end

    [/^#{pattern}$/, keys]
  end


  extend Kiwi::Hooks


  def initialize
    @app       = self
    @hooks     = self.class.hooks
  end


  def call env
    response = try_call(env)
    raise RouteNotFound, "No route for #{env['REQUEST_PATH']}" unless response

  rescue HTTPError => err
    status err.class::STATUS

  rescue => err
    status 500
    @body = may_respond{ trigger err.class, err } || err

  ensure
    may_respond{ trigger :after }
  end


  def try_call env
    may_respond do
      trigger :before

      resource, path_params = find_resource env

      raise RouteNotImplemented,
        "#{env['HTTP_METHOD']} not implemented on #{resource}" unless
          resource.implements? env['HTTP_METHOD']

      if !resource
        child_apps.each{|app| app.call(env) }
      else
        resource.new(self).call env
      end
    end
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
    return unless @app.hooks[hook]
    instance_exec(*args, &@app.hooks[hook])
  end


  ##
  # End the HTTP request and send the response.
  # Throws :respond.

  def respond *args
    args[0..2].each do |arg|
      case arg
      when Fixnum then  @response[0] = arg
      when Hash   then  (@response[1] ||= {}).merge! arg
      else
        @response[2] = arg.respond_to?(:each) ? arg : [arg]
      end
    end

    throw :respond
  end


  ##
  # Exit the current code path and render the response.

  def render body=nil
    @body = body if body
    throw :respond, body
  end


  ##
  # Respond with a 301, 302, 303, or 307 redirect. Defaults to 302.
  # Calling this method will exit the current code path.
  #
  #   redirect "/new_location/123"
  #   #=> 302 redirect
  #
  #   redirect 307, "/new_location/123"
  #   #=> client must redirect with same http method
  #
  #   redirect "/new_location/123", "Go seomwhere else"
  #   #=> 302 redirect with response body

  def redirect code, location=nil, body=nil
    code, location, body = 302, code, location if String === code

    status  code
    headers 'Location' => location
    render  body
  end


  attr_accessor :app, :env, :request, :response

  private


  def may_respond &block
    catch(:respond, &block)
  end


  ##
  # Make the request.

  def request! env
    @app = self
    @env = env

    @request = Rack::Request.new env

    @params = @req.params
    @body   = nil

    @response = [200, {'Content-Type' => "application/json"}]


    ept, @app = find_endpoint @env unless ept
    @endpoint = ept if Kiwi::Endpoint === ept

    begin
      @body = catch(:respond) do
        trigger :before

        raise ept if Exception === ept
        @endpoint.call self
      end

      @body = @endpoint.view.new(@body).to_hash if @endpoint.view

    rescue HTTPError => err
      status err.class::STATUS

    rescue => err
      status 500
      @body = catch(:respond){ trigger err.class, err } || err
    end

    catch(:respond) do
      @body = trigger(@response[0]) || @body
      trigger :after
    end

    finalize_response @body
  end


  ##
  # Creates a Rack response array from the given data.

  def finalize_response data
    if Exception === data
      data = {"error" => data.class, "message" => data.message}
      data['trace'] = data.backtrace if Kiwi.trace
    end

    data = data.to_json unless
      String === data || Numeric === data || data.respond_to?(:read)

    data = [data.to_s] unless data.respond_to?(:each) && !(String === data)

    @response[2] = data
    @response
  end


  ##
  # Returns a resource object if it exists.
  # Returns RouteNotFound if no resource is found.
  # Returns RouteNotImplemented if no action exists for the http verb.

  def find_resource env
    (matcher, keys), resource = resources.find do |(matcher, keys), r|
      env['REQUEST_PATH'] =~ matcher
    end

    [resource, matches]
  end
end
