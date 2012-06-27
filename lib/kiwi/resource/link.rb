class Kiwi::Resource::Link < Kiwi::Resource

  route "_link"
  desc  "View and list links for various resources"

  view Kiwi::View::Link

  param.string :id,
    :desc => "Combination of [resource_type]-[method]",
    :only => :get

  param.string :resource,
    :desc     => "The resource name to lookup",
    :optional => true,
    :only     => :list

  param.string :rid,
    :desc     => "Id of a resource instance to get a link for",
    :optional => true


  def get id
    rsc_klass, rsc_method = @params[:id].split "-"
    rsc_klass = @app.find_resource(rsc_klass)

    return unless rsc_klass && rsc_method

    rsc_klass.link_for(rsc_method.to_sym, @params[:rid]).to_hash
  end


  def list
    if @params[:resource]
      rsc_klass = @app.find_resource @params[:resource]
      return [] unless rsc_klass

      rsc_klass.links(@params[:rid]).map(&:to_hash)

    else
      @app.resources.map{|rsc| rsc.links(@params[:rid]).map(&:to_hash)}.flatten
    end
  end
end
