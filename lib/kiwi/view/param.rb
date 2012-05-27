class Kiwi::View::Param < Kiwi::View

  string  :name
  string  :type
  string  :desc,       :optional => true
  string  :default,    :optional => true
  string  :values,     :optional => true, :collection => true
  boolean :collection, :optional => true
  boolean :optional,   :optional => true
  view :attributes, Kiwi::View::Param, :collection => true, :optional => true
end
