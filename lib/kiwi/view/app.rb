class Kiwi::View::App < Kiwi::View

  string :api_name
  string :mime_types, :collection => true

  collection :resources do |rsc|
    rsc.string :id
    rsc.link :link
  end
end
