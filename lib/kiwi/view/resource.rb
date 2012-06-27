class Kiwi::View::Resource < Kiwi::View

  string   :name, :desc => "The Resource type identifier"
  string   :desc, :optional => true, :desc => "Description of the resource"
  resource :links,      "Kiwi::Resource::Link",      :collection => true
  resource :attributes, "Kiwi::Resource::Attribute", :collection => true
end
