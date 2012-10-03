class Kiwi::View::Attribute < Kiwi::View

  string   :name,       :desc => "Name of the attribute"
  string   :type,       :desc => "Data type of the attribute"
  string   :label,      :desc => "Label of the attribute",    :optional => true
  string   :desc,       :desc => "Attribute description",     :optional => true
  string   :default,    :desc => "Default used when omitted", :optional => true
  boolean  :collection, :desc => "Attribute is an array",     :optional => true
  boolean  :optional,   :desc => "Attribute is optional",     :optional => true

  string   :value,      :desc => "Currently assigned value",  :optional => true

  collection :values, :desc => "Array of allowable values", :optional => true do |c|
    c.string :name,  :desc => "Display name", :optional => true
    c.string :value, :desc => "Value of this option"
  end

  resource :attributes, "Kiwi::Resource::Attribute",
    :collection => true, :optional => true,
    :desc => "Unfolds embedded attributes for anonymous sub-views"
end
