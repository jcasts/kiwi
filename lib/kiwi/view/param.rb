class Kiwi::View::Param < Kiwi::View

  string   :name
  string   :type
  string   :desc,       :optional => true
  string   :default,    :optional => true
  string   :values,     :optional => true, :collection => true
  boolean  :collection, :optional => true
  boolean  :optional,   :optional => true
  resource :attributes, "Kiwi::Resource::Attribute",
    :collection => true, :optional => true,
    :desc => "Unfolds embedded attributes for anonymous sub-views"
end
