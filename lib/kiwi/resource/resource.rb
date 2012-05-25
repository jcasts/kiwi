class Kiwi::Resource::Resource < Kiwi::Resource

  route "_resource"

  view Kiwi::View::Resource

  param.string :id,
    :desc => "The Resource type identifier",
    :only => :get


  def get id
    rsc_klass = Kiwi.find_const(@params[:id])
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

