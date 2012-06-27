class Kiwi::View::Link < Kiwi::View

  string :id, :optional => true
  string :method, :desc => "The HTTP verb to use"
  string :href,   :desc => "The path of the HTTP request"
  string :desc, :optional => true

  resource :params, "Kiwi::Resource::Attribute",
    :collection => true, :optional => true
end
