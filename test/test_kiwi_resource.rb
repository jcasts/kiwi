require 'test/helper'

class TestKiwiResource < Test::Unit::TestCase
  class Foo < Kiwi::Resource; end

  def setup
    FooResource.route "/foo_resource"
    FooResource.desc "Foo Resource"
    FooResource.identifier :id
  end


  def test_init
    assert_equal "/test_kiwi_resource/foo", Foo.route.path
    assert_equal :id, Foo.identifier

    assert_equal 1, Foo.redirects.length
    assert_equal :get, Foo.redirects[:options][:method]
    assert_equal Kiwi::Resource::Resource, Foo.redirects[:options][:resource]
    assert_equal Proc, Foo.redirects[:options][:proc].class
  end


  def test_attribs
    FooResource.desc "Foo Resource"
    FooResource.identifier "blah"
    FooResource.redirect :blah, Kiwi::Resource::App, :get
    FooResource.view FooView
    FooResource.preview FooView

    assert_equal "Foo Resource", FooResource.desc
    assert_equal :blah, FooResource.identifier
    assert_equal FooView, FooResource.view
    assert_equal FooView, FooResource.preview
    assert_equal Kiwi::Resource::App, FooResource.redirects[:blah][:resource]
    assert_equal :get, FooResource.redirects[:blah][:method]
  end


  def test_route
    FooResource.route "//foo/bar/"
    assert_equal "//foo/bar", FooResource.route.path
    assert FooResource.routes?("//foo/bar"), "Resource should route //foo/bar"
    assert FooResource.routes?("//foo/bar/"), "Resource should route //foo/bar/"
    assert FooResource.routes?("//foo/bar/123"),
      "Resource should route //foo/bar/123"
  end


  def test_preview_from
    view = FooResource.preview_from :foo => "blah", :bar => "thing"
    assert FooResource.preview
    assert_equal({"foo" => "blah"}, view)
  end


  def test_preview_from_no_view
    view = Foo.preview_from :foo => "blah", :bar => "thing"
    assert Foo.preview.nil?
    assert_equal({:foo => "blah", :bar => "thing"}, view)
  end


  def test_view_from
    view = FooResource.view_from :foo => "blah", :bar => "thing"
    assert FooResource.view
    assert_equal({"foo" => "blah"}, view)
  end


  def test_view_from_no_view
    view = Foo.view_from :foo => "blah", :bar => "thing"
    assert Foo.view.nil?
    assert_equal({:foo => "blah", :bar => "thing"}, view)
  end


  def test_links_for_id
    expected = [
     {:href=>"/foo_resource/123",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]},
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}]

    assert_equal expected, FooResource.links_for('123')
  end


  def test_links_for_generic
    expected = [
     {:href=>"/foo_resource/:id",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]},
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}]

    assert_equal expected, FooResource.links_for(nil)
  end


  def test_link_for_generic
    expected_get =
     {:href=>"/foo_resource/:id",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]}

    expected_list =
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}

    assert_equal expected_get, FooResource.link_for(:get, nil)
    assert_equal expected_list, FooResource.link_for(:list, nil)
  end


  def test_link_for_generic
    expected_get =
     {:href=>"/foo_resource/123",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]}

    expected_list =
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}

    assert_equal expected_get, FooResource.link_for(:get, "123")
    assert_equal expected_list, FooResource.link_for(:list, "123")
  end


  def test_to_hash
    hash = FooResource.to_hash
    expected = {
      :type  => "FooResource",
      :links =>
[{:href=>"/foo_resource/:id",
    :method=>"GET",
    :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]},
   {:href=>"/foo_resource",
    :method=>"LIST",
    :params=>[]}],

      :attributes =>
[{:name=>"_type", :type=>"String", :optional=>true},
   {:name=>"_links",
    :type=>"Kiwi::Resource::Link",
    :collection=>true,
    :optional=>true},
   {:name=>"foo", :type=>"String"}],

    :desc=>"Foo Resource"

    }

    assert_equal expected, hash
  end
end
