class Kiwi::View::Link < Kiwi::View

  string :id, :optional => true
  string :method
  string :href
  string :desc, :optional => true

  view :params, Kiwi::View::Param, :collection => true
end
