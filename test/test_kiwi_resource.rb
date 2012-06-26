require 'test/helper'

class TestKiwiResource < Test::Unit::TestCase
  class Foo < Kiwi::Resource; end

  def setup
    FooResource.route "/foo_resource"
    FooResource.desc "Foo Resource"
    FooResource.param.clear
    FooResource.identifier false
    InheritedResource.identifier false
  end


  def test_init
    assert_equal "/test_kiwi_resource/foo", Foo.route.path
    assert_equal :id, Foo.identifier

    assert_equal 1, Foo.redirects.length
    assert_equal :get, Foo.redirects[:options][:method]
    assert_equal Kiwi::Resource::Resource, Foo.redirects[:options][:resource]
    assert_equal Proc, Foo.redirects[:options][:proc].class
    assert_equal :id, Foo.__send__(:default_id_param).name
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


  def test_route_join_parts
    FooResource.route "/", "bar", "foo"
    assert_equal "//bar/foo", FooResource.route.path
    assert FooResource.routes?("//bar/foo"), "Resource should route //foo/bar"
    assert FooResource.routes?("//bar/foo/"), "Resource should route //foo/bar/"
    assert FooResource.routes?("//bar/foo/123"),
      "Resource should route //bar/foo/123"
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


  def test_links_id
    expected = [
     {:href=>"/foo_resource/123",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]},
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}]

    assert_equal expected, FooResource.links('123').map(&:to_hash)
  end


  def test_links_generic
    expected = [
     {:href=>"/foo_resource/:id",
      :method=>"GET",
      :params=>[{:name=>"id", :type=>"String", :desc=>"Id of the resource"}]},
     {:href=>"/foo_resource",
      :method=>"LIST",
      :params=>[]}]

    assert_equal expected, FooResource.links(nil).map(&:to_hash)
    assert_equal expected, FooResource.links.map(&:to_hash)
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

    assert_equal expected_get, FooResource.link_for(:get, nil).to_hash
    assert_equal expected_get, FooResource.link_for(:get).to_hash
    assert_equal expected_list, FooResource.link_for(:list, nil).to_hash
    assert_equal expected_list, FooResource.link_for(:list).to_hash
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

    assert_equal expected_get, FooResource.link_for(:get, "123").to_hash
    assert_equal expected_list, FooResource.link_for(:list, "123").to_hash
  end


  def test_link_for_bad_method_name
    assert_raises Kiwi::MethodNotAllowed do
      FooResource.link_for(:lsKDFJ, "123")
    end
  end


  def test_link_to
    FooResource.param.string :bar, :optional => true

    expected = {:href => "/foo_resource/123?bar=1", :method => "GET"}
    assert_equal expected, FooResource.link_to(:get, :id => "123", :bar => "1")

    expected = {:href => "/foo_resource?bar=1", :method => "LIST"}
    assert_equal expected, FooResource.link_to(:list, :id => "123", :bar => "1")
  end


  def test_link_to_bad_method_name
    assert_raises Kiwi::MethodNotAllowed do
      FooResource.link_to(:lsKDFJ)
    end
  end


  def test_default_id_param
    id = FooResource.__send__ :default_id_param
    assert_equal Kiwi::Param, id.class
    assert_equal FooResource.identifier, id.name.to_sym
    assert_equal String, id.type
    assert_equal "Id of the resource", id.desc
  end


  def test_identifier
    assert_equal :id, FooResource.identifier

    FooResource.identifier :myid
    assert_equal :myid, FooResource.identifier

    FooResource.identifier false
    assert_equal :id, FooResource.identifier
  end


  def test_param
    assert_equal Kiwi::ParamSet, Foo.param.class

    Foo.param do
      string :blah
    end

    Foo.param.integer :bar

    assert_equal String,  Foo.param[:blah].type
    assert_equal Integer, Foo.param[:bar].type
  end


  def test_params_for_method
    params = FooResource.params_for_method :get
    assert_equal [:id], params.map(&:name)
  end


  def test_params_for_method_only
    FooResource.param do
      string :all
      string :only_bar, :only => :bar
    end

    params = FooResource.params_for_method :bar
    assert_equal [:all, :only_bar], params.map(&:name)

    params = FooResource.params_for_method :get
    assert_equal [:id, :all], params.map(&:name)
  end


  def test_params_for_method_custom_id_param
    FooResource.identifier :myid

    params = FooResource.params_for_method :get
    assert_equal [], params

    FooResource.param.string :myid, :except => :list

    params = FooResource.params_for_method :get
    assert_equal [:myid], params.map(&:name)

    params = FooResource.params_for_method :list
    assert_equal [], params.map(&:name)
  end


  def test_resource_methods
    assert_equal [:get, :list],        FooResource.resource_methods
    assert_equal [:post, :get, :list], InheritedResource.resource_methods
  end


  def test_id_resource_methods
    assert_equal [:get],        FooResource.id_resource_methods
    assert_equal [:post, :get], InheritedResource.id_resource_methods
  end


  def test_id_resource_methods_inherited_identifier
    FooResource.identifier :myid
    assert_equal [], FooResource.id_resource_methods
    assert_equal [], InheritedResource.id_resource_methods
  end


  def test_id_resource_methods_inherited_custom_identifier
    InheritedResource.identifier :id
    FooResource.identifier :myid
    assert_equal [],            FooResource.id_resource_methods
    assert_equal [:post, :get], InheritedResource.id_resource_methods
  end


  def test_redirects
    block = lambda{|params| puts "foo" }

    Foo.redirect "my_method", InheritedResource, &block
    assert_equal :my_method, Foo.redirects[:my_method][:method]
    assert_equal block, Foo.redirects[:my_method][:proc]

    Foo.redirect "my_method", InheritedResource, :post
    assert_equal :post, Foo.redirects[:my_method][:method]
    assert_nil Foo.redirects[:my_method][:proc]
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
