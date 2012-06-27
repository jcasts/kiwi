require "test/unit"
require "kiwi"


class FooView < Kiwi::View
  string :foo

  optional

  string :id
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


class TestApp < Kiwi::App
  resource FooResource
  resource InheritedResource
end

TEST_APP = TestApp.new


class Kiwi::Test::Resource < Test::Unit::TestCase

  private

  def resource_body_for rsc_name
    Kiwi::Resource::Resource.new(TEST_APP).
      call(:get, "/_resource/#{rsc_name}", {})
  end

  def link_body_for rsc_name
    Kiwi::Resource::Link.new(TEST_APP).
      call(:get, "/_link/#{rsc_name}", {})
  end

  def links_body_for rsc_name
    Kiwi::Resource::Link.new(TEST_APP).
      call(:list, "/_link", {:resource => rsc_name})
  end
end
