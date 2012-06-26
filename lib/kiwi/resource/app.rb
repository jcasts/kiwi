class Kiwi::Resource::App < Kiwi::Resource

  route Kiwi::Route.delimiter
  desc  "A resource representation of this application"

  view Kiwi::View::App
  param.delete :id

  def get
    resources = @app.resources.map do |rsc|
      {
        :id   => rsc.name,
        :link => rsc.link_for(:options, rsc.name).to_hash
      }
    end

    {
      :api_name   => @app.api_name,
      :mime_types => @app.mime_types,
      :resources  => resources,
    }
  end
end
