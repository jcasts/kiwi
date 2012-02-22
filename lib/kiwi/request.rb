##
# Instance of a request made to the App. All requests run in this context.

# TODO:
# * Handle redirect and reroute

class Kiwi::Request

  attr_reader :app, :env, :response

  ##
  # Create a request instance of the app.

  def initialize app
    @app = app
    @response = [200, {'Content-Type' => "application/json"}]
  end


  ##
  # Make the request.

  def call env
    @env = env

    trigger :before

    begin
      endpoint, @app = find_endpoint! @env
      endpoint.validate! @env if Kiwi.param_validation
      data = instance_eval endpoint.action

    rescue HTTPError => err
      status err.class::STATUS

    rescue => err
      status 500
      data = err
      trigger err.class, err
    end

    trigger @response[0]
    trigger :after

    render data
  end


  ##
  # Trigger any application hook.

  def trigger hook, *args
    return unless @app.hooks[hook]
    instance_exec(*args, &@app.hooks[hook])
  end


  ##
  # Creates a Rack response array from the given data.

  def render data
    if Exception === data
      data = {"error" => data.class, "message" => data.message}
      data['trace'] = data.backtrace if Kiwi.trace
    end

    @response[2] = [data.to_json]
    @response
  end


  ##
  # Returns an endpoint object if it exists.
  # Raises RouteNotFound if no endpoint is found.
  # Raises RouteNotImplemented if no action exists for the route.

  def find_endpoint! env
    endpoint, context_app = @app.endpoints[env['HTTP_METHOD']].
                      find{|(ept, app)| ept.routes? env }

    raise RouteNotFound,
      "No route for #{env['REQUEST_PATH']}" unless endpoint

    raise RouteNotImplemented,
      "#{endpoint.path_name} isn't implemented" unless endpoint.action

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
