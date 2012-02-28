##
# Method set to describe a Kiwi app.

module Kiwi::DSL

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
  # Define a PATCH endpoint.

  def patch path, &action
    finalize_ept "PATCH", path, &action
  end


  ##
  # Define a POST endpoint.

  def post path, &action
    finalize_ept "POST", path, &action
  end


  ##
  # Define a PUT endpoint.

  def put path, &action
    finalize_ept "PUT", path, &action
  end


  ##
  # Define a DELETE endpoint.

  def delete path, &action
    finalize_ept "DELETE", path, &action
  end


  ##
  # Define a OPTIONS endpoint.

  def options path, &action
    finalize_ept "OPTIONS", path, &action
  end


  ##
  # Create an endpoint with a custom http verb.

  def route http_method, path, &action
    finalize_ept http_method, path, &action
  end


  private

  def finalize_ept http_method, path, &action # :nodoc:
    # TODO: Allow raising an error if no description is given?
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
