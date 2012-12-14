class Kiwi::Resource::App < Kiwi::Resource

  FILTER = [:name, :details, :desc]

  desc  "A resource representation of this application"

  view Kiwi::View::App
  param.delete :id


  def get
    resources = @app.resources.map do |rsc|
      hash = rsc.new(@app).to_hash.select{|k, v| FILTER.include?(k) }
      Kiwi::Resource::Resource.build hash
    end

    {
      :api_name   => @app.api_name,
      :mime_types => @app.mime_types.map(&:to_s),
      :resources  => resources,
    }
  end
end
