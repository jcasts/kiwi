##
# Method set to describe a Kiwi app.

module Kiwi::DSL

  ##
  # Accessor for all endpoints.

  def endpoints
    @@endpoints ||= {}
  end


  ##
  # Assign a hook for error or status handling.
  #   hook(404){ "OH NOES" }
  #   hook(502..504, 599){ "EVIL GATEWAY" }
  #   hook(MyException){ "do something special" }

  def hook *names, &block
    @hooks ||= {}
    names.each do |name|
      if Range === name
        name.each{|n| @hooks[n] = block }
      else
        @hooks[name] = block
      end
    end
  end


  ##
  # Assign a prefix to all endpoint paths.

  def prefix path
    @prefix = path
  end


  ##
  # Describe an endpoint.

  def desc string
    future_ept.description = string
  end


  ##
  # Describe params for an endpoint.

  def param
    future_ept.params
  end


  ##
  # Assign a view for a given endpoint.

  def view name_or_class
    # TODO: support passing a presenter as well?
    future_ept.view = name_or_class
  end


  ##
  # Define a GET endpoint.

  def get path, &action
    finalize_ept "GET", path, &action
  end


  ##
  # Define a POST endpoint.

  def post path, &action
    finalize_ept "POST", path, &action
  end


  ##
  # Define a POST endpoint.

  def put path, &action
    finalize_ept "PUT", path, &action
  end


  ##
  # Define a DELETE endpoint.

  def delete path, &action
    finalize_ept "DELETE", path, &action
  end


  ##
  # Create an endpoint with a custom http verb.

  def route http_method, path, &action
    finalize_ept http_method, path, &action
  end


  private

  def finalize_ept http_method, path, &action # :nodoc:
    # TODO: Allow raising an error if no description or view is given?
    http_method = http_method.to_s.upcase

    future_ept.http_method = http_method
    future_ept.path        = path
    future_ept.action      = action

    (endpoints[http_method] ||= []) << future_ept

    ept, @future_endpoint = @future_endpoint, nil
    return ept
  end


  def future_ept # :nodoc:
    @future_endpoint ||= Kiwi::Endpoint.new "GET", prefix
  end
end
