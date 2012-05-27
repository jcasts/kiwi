class Kiwi::Resource::Link < Kiwi::Resource

  route "_link"

  view Kiwi::View::Link

  param.string :id,
    :desc => "Combination of [resource_type]-[method]",
    :only => :get

  param.string :rid,
    :desc     => "Actual id of the resource to get a link from",
    :optional => true

  param.string :resource,
    :optional => true,
    :only     => :list


  def get id
    rsc_klass, rsc_method = @params[:id].split "-"
    rsc_klass = @app.find_resource(rsc_klass)

    return unless rsc_klass && rsc_method

    rsc_klass.link_for(rsc_method.to_sym, @params[:rid])
  end


  def list
    if @params[:resource]
      rsc_klass = @app.find_resource @params[:resource]
      return [] unless rsc_klass

      rsc_klass.links_for(@params[:rid])

    else
      @app.resources.map{|rsc| rsc.links_for(@params[:rid])}.flatten
    end
  end
end
