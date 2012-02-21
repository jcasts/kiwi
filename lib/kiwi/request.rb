##
# Instance of a request made to the App. All requests run in this context.

class Kiwi::Request

  attr_reader :env, :app

  def initialize app, env
    @app = app
    @env = env
    @http_method = env['HTTP_METHOD']
  end


  def call
    endpoint = @app.endpoints[@http_method].find{|ept| ept.routes? @env }

    raise RouteNotFound,
      "No route for #{@env['REQUEST_PATH']}" unless endpoint

    raise RouteNotImplemented,
      "#{endpoint.path_name} isn't implemented" unless endpoint.controller

    endpoint.validate! @env

    data = instance_eval(&endpoint.controller)
    render data

  rescue => err
    render err
  end


  def render data, status=nil
    if Exception === data
      err      = data
      data     = {"error" => data.class, "message" => data.message}
      status ||= data.class.const_defined?("STATUS") ? data.class::STATUS : 500
    end

    # TODO: call status/error hooks

    [(status || 200), {"Content-Type" => "application/json"}, [data.to_json]]
  end
end
