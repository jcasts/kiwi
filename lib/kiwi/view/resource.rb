class Kiwi::View::Resource < Kiwi::View

  string :name, :desc => "Name of the resource"

  optional

  string   :desc, :desc => "Description of the resource"

  resource :details,    "Kiwi::Resource::Link"
  resource :actions,    "Kiwi::Resource::Link",      :collection => true
  resource :attributes, "Kiwi::Resource::Attribute", :collection => true
end
