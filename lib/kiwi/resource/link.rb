class Kiwi::Resource::Link < Kiwi::Resource

  route "_link"

  view Kiwi::View::Link

  param.string :id,
    :desc => "Combination of [resource_route]-[method]",
    :only => :get

  param.string :resource,
    :optional => true,
    :only     => :list


  def get
    rsc_klass, rsc_method = @params[:id].split "-"
    rsc_klass = @app.resource_for rsc_klass

    return unless rsc_klass && rsc_method

    rsc_klass.link_for(rsc_method.to_sym, nil)
  end


  def list
    if @params[:resource]
      rsc_klass = @app.resource_for @params[:resource]
      return [] unless rsc_klass

      rsc_klass.links_for(nil)

    else
      @app.resources.map{|rsc| rsc.links_for(nil)}.flatten
    end
  end
end
