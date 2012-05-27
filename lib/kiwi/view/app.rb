class Kiwi::View::App < Kiwi::View

  string :api_name
  collection :resources do |rsc|
    rsc.string :id
    rsc.link :link
  end
end
