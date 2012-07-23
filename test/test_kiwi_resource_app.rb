require 'test/helper'

class TestKiwiResourceApp < Kiwi::Test::Resource

  def setup
    @app_rsc = Kiwi::Resource::App.new TEST_APP
  end


  def test_get
    expected =
{:_type=>"Kiwi::Resource::App",
 :api_name=>"TestApp",
 :mime_types=>["application/TestApp+json"],
 :resources=>
  [{:_type=>"Kiwi::Resource::Resource",
    :name=>"Kiwi::Resource::Resource",
    :desc=>"Show the links and attributes of any resource.",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/Kiwi::Resource::Resource"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"Kiwi::Resource::Link",
    :desc=>"View and list links for various resources",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/Kiwi::Resource::Link"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"Kiwi::Resource::App",
    :desc=>"A resource representation of this application",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/Kiwi::Resource::App"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"Kiwi::Resource::Attribute",
    :desc=>"Representation of an attribute",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/Kiwi::Resource::Attribute"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"Kiwi::Resource::Error",
    :desc=>"Representation of an application error",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/Kiwi::Resource::Error"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"FooResource",
    :desc=>"Foo Resource",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/FooResource"}},
   {:_type=>"Kiwi::Resource::Resource",
    :name=>"InheritedResource",
    :details=>
     {:_type=>"Kiwi::Resource::Link",
      :method=>"get",
      :href=>"/_resource/InheritedResource"}}]}

    assert_equal expected, @app_rsc.call(:get, "/", {})
  end
end
