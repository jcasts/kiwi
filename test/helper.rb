require "test/unit"
require "kiwi"

class FooView < Kiwi::View
  string :foo
end

class FooResource < Kiwi::Resource
  view FooView

  def get id
    {:foo => "myfoo"}
  end

  def list
    [{:foo => "myfoo"}]
  end
end


class InheritedResource < FooResource
  view FooView

  def post id
    {:foo => "myfoo"}
  end
end

class ViewlessResource < Kiwi::Resource
end
