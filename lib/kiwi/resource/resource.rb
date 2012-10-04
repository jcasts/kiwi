class Kiwi::Resource::Resource < Kiwi::Resource
  desc  "Show the links and attributes of any resource."

  view Kiwi::View::Resource

  param.string :id,
    :desc => "The Resource type identifier",
    :only => :get


  def get id
    rsc_klass = @app.find_resource(@params[:id])
    return unless rsc_klass

    hash = rsc_klass.new(@app).to_hash
    hash.delete :details
    hash
  end


  def list
    @app.resources.map do |rsc_klass|
      hash = rsc_klass.new(@app).to_hash
      hash.delete[:actions]
      hash
    end
  end
end
