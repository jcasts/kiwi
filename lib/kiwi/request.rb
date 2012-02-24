##
# Instance of a request made to the App. All requests run in this context.

class Kiwi::Request

  attr_reader :app, :env, :endpoint, :response

  ##
  # Create a request instance of the app.

  def initialize app
    @app = app
    @response = [200, {'Content-Type' => "application/json"}]
  end


  ##
  # Make the request.

  def call env
    @env  = env
    @body = nil

    ept, @app = find_endpoint! @env
    @endpoint = ept if Kiwi::Endpoint === ept

    begin
      @body = catch(:render) do
        trigger :before

        raise ept if Exception === ept

        @endpoint.validate! self if Kiwi.param_validation
        @endpoint.call self
      end

      @body = @endpoint.view.new(@body).to_hash if @endpoint.view

    rescue HTTPError => err
      status err.class::STATUS

    rescue => err
      status 500
      @body = catch(:render){ trigger err.class, err } || err
    end

    catch(:render) do
      @body = trigger(@response[0]) || @body
      trigger :after
    end

    finalize_response @body
  end


  ##
  # Trigger any application hook.

  def trigger hook, *args
    return unless @app.hooks[hook]
    instance_exec(*args, &@app.hooks[hook])
  end


  ##
  # Exit the current code path and render the response.

  def render body=nil
    @body = body if body
    throw :render, body
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


  ##
  # Returns an endpoint object if it exists.
  # Returns RouteNotFound if no endpoint is found.
  # Returns RouteNotImplemented if no action exists for the route.

  def find_endpoint! env
    endpoint, context_app = @app.endpoints[env['HTTP_METHOD']].
                      find{|(ept, app)| ept.routes? env }

    context_app ||= @app

    endpoint =
      RouteNotImplemented.new "#{endpoint.path_name} not implemented" unless
        endpoint && endpoint.action

    endpoint ||= RouteNotFound.new "No route for #{env['REQUEST_PATH']}"

    endpoint, context_app
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
end
