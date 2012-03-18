class Kiwi::View::Link < Kiwi::View

  string :method
  string :href
  string :desc, :optional => true

  collection :params, :optional => true do |params|
    params.string  :name
    params.string  :type
    params.string  :desc, :optional => true
    params.boolean :collection, :default => false
    params.string  :default, :optional => true
    params.string  :values,  :optional => true, :collection => true
  end
end
