require "test/unit"
require "kiwi"

class FooView < Kiwi::View
  string :foo
end

class FooResource < Kiwi::Resource
  view FooView
end

class ViewlessResource < Kiwi::Resource
end
