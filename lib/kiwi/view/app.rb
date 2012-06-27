class Kiwi::View::App < Kiwi::View

  string :api_name
  string :mime_types, :collection => true

  resource :resources, "Kiwi::Resource::Resource", :collection => true
end
