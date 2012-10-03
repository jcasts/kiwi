class Kiwi::View::Attribute < Kiwi::View

  string   :name,       :desc   => "Name of the attribute"
  string   :type,       :desc   => "Data type of the attribute",
                        :values => %w{String Integer Float}

  optional

  string   :display,    :desc   => "Display type",
                        :values => %w{normal hidden textarea}

  string   :label,      :desc => "Display name"
  string   :desc,       :desc => "Attribute description"

  string   :default,    :desc => "Default used when omitted"
  boolean  :collection, :desc => "Attribute is an array"
  boolean  :optional,   :desc => "Attribute is optional"

  string   :value,      :desc => "Currently assigned value"

  collection :values, :desc => "Array of allowable values" do |c|
    c.string :label, :desc => "Display name", :optional => true
    c.string :value, :desc => "Value of this option"
  end

  resource :attributes, "Kiwi::Resource::Attribute", :collection => true,
    :desc => "Unfolds embedded attributes for anonymous sub-views"
end
