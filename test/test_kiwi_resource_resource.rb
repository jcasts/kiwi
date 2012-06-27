require 'test/helper'

class TestKiwiResourceResource < Test::Unit::TestCase

  def test_fooresource_resource
    expected = {
      :_type=>"Kiwi::Resource::Resource",
      :name  => "FooResource",
      :links =>
  [{:_type=>"Kiwi::Resource::Link",
    :href=>"/foo_resource/:id",
    :method=>"GET",
    :params=>[
     {:_type=>"Kiwi::Resource::Attribute",
      :name=>"id",
      :type=>"String",
      :desc=>"Id of the resource"}]},
   {:_type=>"Kiwi::Resource::Link",
    :href=>"/foo_resource",
    :method=>"LIST",
    :params=>[]}],

      :attributes =>
  [{:_type=>"Kiwi::Resource::Attribute",
    :name=>"_type",
    :type=>"String",
    :optional=>true},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"_links",
    :type=>"Kiwi::Resource::Link",
    :collection=>true,
    :optional=>true},
   {:_type=>"Kiwi::Resource::Attribute", :name=>"foo", :type=>"String"},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"id",
    :type=>"String",
    :optional => true}],

    :desc=>"Foo Resource"

    }

    assert_equal expected, resource_body_for(FooResource)
  end


  def test_resource_resource
    expected =
{:_type=>"Kiwi::Resource::Resource",
 :name=>"Kiwi::Resource::Resource",
 :desc=>"Show the links and attributes of any resource.",
 :links=>
  [{:_type=>"Kiwi::Resource::Link",
    :method=>"GET",
    :href=>"/_resource/:id",
    :params=>
     [{:_type=>"Kiwi::Resource::Attribute",
       :name=>"id",
       :type=>"String",
       :desc=>"The Resource type identifier"}]},
   {:_type=>"Kiwi::Resource::Link",
    :method=>"LIST",
    :href=>"/_resource",
    :params=>[]}],
 :attributes=>
  [{:_type=>"Kiwi::Resource::Attribute",
    :name=>"_type",
    :type=>"String",
    :optional=>true},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"_links",
    :type=>"Kiwi::Resource::Link",
    :collection=>true,
    :optional=>true},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"name",
    :type=>"String",
    :desc=>"The Resource type identifier"},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"desc",
    :type=>"String",
    :desc=>"Description of the resource",
    :optional=>true},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"links",
    :type=>"Kiwi::Resource::Link",
    :collection=>true},
   {:_type=>"Kiwi::Resource::Attribute",
    :name=>"attributes",
    :type=>"Kiwi::Resource::Attribute",
    :collection=>true}]}

    assert_equal expected, resource_body_for(Kiwi::Resource::Resource)
  end


  private

  def resource_body_for rsc_name
    Kiwi::Resource::Resource.new(TEST_APP).
      call(:get, "/_resource/#{rsc_name}", {})
  end
end
