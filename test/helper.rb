require "test/unit"
require "kiwi"


class FooView < Kiwi::View
  string :foo

  optional

  string :id
end

class FooResource < Kiwi::Resource
  view FooView
  preview FooView

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


class TestApp < Kiwi::App
  resource FooResource
  resource InheritedResource
end

TEST_APP = TestApp.new
