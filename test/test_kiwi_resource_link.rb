require 'test/helper'

class TestKiwiResourceLink < Kiwi::Test::Resource

  def test_link_link
    expected = {
     :_type=>"Kiwi::Resource::Link",
     :id=>"Kiwi::Resource::Link-get",
     :method=>"GET",
     :href=>"/_link/:id",
     :params=>
      [{:_type=>"Kiwi::Resource::Attribute",
        :name=>"id",
        :type=>"String",
        :desc=>"Combination of [resource_type]-[method]"},
       {:_type=>"Kiwi::Resource::Attribute",
        :name=>"rid",
        :type=>"String",
        :desc=>"Id of a resource instance to get a link for",
        :optional=>true}]}

    assert_equal expected, link_body_for("Kiwi::Resource::Link-get")
  end


  def test_link_links
    expected = [
     {:_type=>"Kiwi::Resource::Link",
      :method=>"GET",
      :href=>"/_link/:id",
      :params=>
       [{:_type=>"Kiwi::Resource::Attribute",
         :name=>"id",
         :type=>"String",
         :desc=>"Combination of [resource_type]-[method]"},
        {:_type=>"Kiwi::Resource::Attribute",
         :name=>"rid",
         :type=>"String",
         :desc=>"Id of a resource instance to get a link for",
         :optional=>true}]},
     {:_type=>"Kiwi::Resource::Link",
      :method=>"LIST",
      :href=>"/_link",
      :params=>
       [{:_type=>"Kiwi::Resource::Attribute",
         :name=>"rid",
         :type=>"String",
         :desc=>"Id of a resource instance to get a link for",
         :optional=>true},
        {:_type=>"Kiwi::Resource::Attribute",
         :name=>"resource",
         :type=>"String",
         :desc=>"The resource name to lookup",
         :optional=>true}]}]

    assert_equal expected, links_body_for("Kiwi::Resource::Link")
  end
end
