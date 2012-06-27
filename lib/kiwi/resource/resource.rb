class Kiwi::Resource::Resource < Kiwi::Resource

  route "_resource"
  desc  "Show the links and attributes of any resource."

  view Kiwi::View::Resource

  param.string :id,
    :desc => "The Resource type identifier",
    :only => :get


  def get id
    rsc_klass = @app.find_resource(@params[:id])
    return unless rsc_klass

    rsc_klass.to_hash
  end


  def list
    @app.resources.map do |rsc_klass|
      rsc_klass.to_hash
    end
  end
end

