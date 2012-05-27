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

    hashify rsc_klass
  end


  def list
    @app.resources.map do |rsc_klass|
      hashify rsc_klass
    end
  end


  private

  def hashify rsc_klass
    out = rsc_klass.to_hash
    out[:id] = out.delete :type
    out
  end
end

