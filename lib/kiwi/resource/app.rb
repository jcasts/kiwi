class Kiwi::Resource::App < Kiwi::Resource

  route "/"
  desc  "A resource representation of this application"

  view Kiwi::View::App
  param.delete :id

  def get
    resources = @app.resources.map do |rsc|
      {
        :id   => rsc.name,
        :link => rsc.link_for(:options, rsc.name)
      }
    end

    {:api_name => @app.api_name, :resources => resources}
  end
end
