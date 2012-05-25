class Kiwi::View::Resource < Kiwi::View

  string :id,         :desc => "The Resource type identifier"
  view   :links,      Kiwi::View::Link,  :collection => true
  view   :attributes, Kiwi::View::Param, :collection => true
end
