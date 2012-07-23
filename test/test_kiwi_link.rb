require 'test/helper'

class TestKiwiLink < Test::Unit::TestCase

  def setup
    @params = Kiwi::ParamSet.new

    @params.instance_eval do
      string :id
      string :foo

      optional

      boolean :bar
      integer :int, :collection => true
      subset :sub do |sub|
        sub.string :col, :collection => true
        sub.string :str
      end
    end

    @link = Kiwi::Link.new "post", "/foo/bar/:id", @params.v_attributes.values
  end


  def test_init
    assert_equal "post", @link.rsc_method
    assert_equal "/foo/bar/:id", @link.path
    assert_equal @params.v_attributes.values, @link.params
  end


  def test_build
    expected = {
      :href   => "/foo/bar/123?foo=bar&bar=true",
      :method => "post"
    }

    assert_equal expected, @link.build(:id => "123", :foo => "bar", :bar => true)
  end


  def test_build_missing_param
    assert_raises Kiwi::RequiredValueError, 'No `foo\' in {:id=>"123"}' do
      @link.build(:id => "123")
    end
  end


  def test_build_collection
    expected = {
      :href   => "/foo/bar/123?foo=bar&int[]=1&int[]=2",
      :method => "post"
    }

    assert_equal expected, @link.build(:id => "123",
      :foo => "bar", :int => [1,2])
  end


  def test_build_subset
    expected = {
      :href   => "/foo/bar/123?foo=bar&sub[col][]=1&sub[col][]=2&sub[str]=val",
      :method => "post"
    }

    assert_equal expected, @link.build(:id => "123", :foo => "bar",
      :sub => {:col => %w{1 2}, :str => "val"})
  end


  def test_to_hash
    expected = {
      :href   => "/foo/bar/:id",
      :method => "post",
      :params => [
       {:name=>"id", :type=>"String"},
       {:name=>"foo", :type=>"String"},
       {:name=>"bar", :type=>"Boolean", :optional=>true},
       {:name=>"int", :type=>"Integer", :collection=>true, :optional=>true},
       {:name=>"sub",
        :attributes=>
         [{:name=>"col", :type=>"String", :collection=>true},
          {:name=>"str", :type=>"String"}],
        :type=>"_embedded",
        :optional=>true}
      ]
    }

    assert_equal expected, @link.to_hash
  end
end
