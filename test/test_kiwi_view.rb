require 'test/helper'

class TestKiwiView < Test::Unit::TestCase

  class PersonView < Kiwi::View
    v_attribute :name,  String
    v_attribute :gender, String, :optional => true

    v_attribute :attributes, :collection => true, :optional => true do |sub|
      sub.v_attribute :awesome, Boolean, :default => false, :optional => true
      sub.v_attribute :awake,   Boolean, :default => false
    end
  end


  class CatView < Kiwi::View
    string  :name
    integer :age
    string  :colors, :collection => true
  end


  def test_v_attribute_name
    v_attribute = PersonView.v_attributes['name']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal false,                 v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_v_attribute_gender
    v_attribute = PersonView.v_attributes['gender']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end



  def test_v_attribute_attributes
    v_attribute = PersonView.v_attributes['attributes']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert       v_attribute.type.ancestors.include?(Kiwi::View)

    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default

    sub_attribute = v_attribute.type.v_attributes['awesome']
    assert_equal Kiwi::View::Attribute, sub_attribute.class
    assert_equal false,                 sub_attribute.collection
    assert_equal true,                  sub_attribute.optional
    assert_equal false,                 sub_attribute.default

    sub_attribute = v_attribute.type.v_attributes['awake']
    assert_equal Kiwi::View::Attribute, sub_attribute.class
    assert_equal false,                 sub_attribute.collection
    assert_equal false,                 sub_attribute.optional
    assert_equal false,                 sub_attribute.default
  end


  def test_string_attribute
    PersonView.string :foo, :optional => true
    v_attribute = PersonView.v_attributes['foo']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_integer_attribute
    PersonView.integer :foo, :optional => true
    v_attribute = PersonView.v_attributes['foo']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal Integer,               v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_boolean_attribute
    PersonView.boolean :foo, :optional => true
    v_attribute = PersonView.v_attributes['foo']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal Boolean,               v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_view_attribute
    PersonView.view :cats, CatView, :optional => true, :collection => true
    v_attribute = PersonView.v_attributes['cats']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert_equal CatView,               v_attribute.type
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_collection_attribute
    PersonView.collection :cats, :optional => true do |cat|
      cat.string  :name
      cat.integer :age
    end

    v_attribute = PersonView.v_attributes['cats']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert       v_attribute.type.ancestors.include?(Kiwi::View)
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_subset_attribute
    PersonView.collection :cats, :optional => true do |cat|
      cat.string  :name
      cat.integer :age
    end

    v_attribute = PersonView.v_attributes['cats']

    assert_equal Kiwi::View::Attribute, v_attribute.class
    assert       v_attribute.type.ancestors.include?(Kiwi::View)
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_build_basic
    res = PersonView.build :name => "John"
    expected = {"name" => "John"}

    assert_equal expected, res
  end


  def test_build_basic_subs
    res = PersonView.build :name => "John", :attributes => [{:awake => true}]
    expected = {"name" => "John",
        "attributes" => [{"awake" => true, "awesome" => false}]}

    assert_equal expected, res
  end


  def test_build_wrong_type
    assert_raises Kiwi::InvalidTypeError do
      PersonView.build :name => 123
    end

    assert_raises Kiwi::InvalidTypeError do
      PersonView.build :name => "John", :attributes => [{:awake => 'foo'}]
    end
  end


  def test_to_hash_basic
    res = PersonView.new(:name => "John").to_hash
    expected = {"name" => "John"}

    assert_equal expected, res
  end


  def test_to_hash_basic_subs
    res = PersonView.
      new(:name => "John", :attributes => [{:awake => true}]).to_hash

    expected = {"name" => "John",
        "attributes" => [{"awake" => true, "awesome" => false}]}

    assert_equal expected, res
  end


  def test_to_hash_wrong_type
    assert_raises Kiwi::InvalidTypeError do
      PersonView.new(:name => 123).to_hash
    end

    assert_raises Kiwi::InvalidTypeError do
      PersonView.
        new(:name => "John", :attributes => [{:awake => 'foo'}]).to_hash
    end
  end


  def test_to_hash_view
    PersonView.view :cats, CatView, :optional => true, :collection => true
    view = PersonView.new :name => "Jack",
            :cats => [
              {:name => "daisy",  :age => 2, :colors => ["black"]},
              {:name => "bandit", :age => 1, :colors => ["white", "black"]}
            ]

    expected = {"name" => "Jack", "cats" =>
      [{"name" => "daisy",  "age" => 2, "colors" => ["black"]},
       {"name" => "bandit", "age" => 1, "colors" => ["white", "black"]}]}

    assert_equal expected, view.to_hash
  end
end
