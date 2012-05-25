class Kiwi::View::Param < Kiwi::View

  string  :name
  string  :type
  string  :desc,       :optional => true
  string  :default,    :optional => true
  string  :values,     :optional => true, :collection => true
  boolean :collection, :default  => false
end
