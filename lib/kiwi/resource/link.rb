class Kiwi::Resource::Link < Kiwi::Resource

  route "/_link/:resource"

  view Kiwi::View::Link


  def get
    rsc_method = @params['id']
    rsc_klass  = @app.resource_for @params['resource']
    return unless rsc_klass

    rsc_klass.link_for(rsc_method, ":id")
  end


  def list
    rsc_klass = @app.resource_for @params['resource']
    return unless rsc_klass

    rsc_klass.links_for(":id")
  end
end
