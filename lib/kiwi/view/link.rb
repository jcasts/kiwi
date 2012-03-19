class Kiwi::View::Link < Kiwi::View

  string :method
  string :href
  string :desc, :optional => true

  collection :params, :optional => true do |param|
    param.string  :name
    param.string  :type
    param.string  :desc, :optional => true
    param.boolean :collection, :default => false
    param.string  :default, :optional => true
    param.string  :values,  :optional => true, :collection => true
  end
end
