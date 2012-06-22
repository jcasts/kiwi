require 'test/helper'

class TestKiwiValidator < Test::Unit::TestCase

  class PersonValidator < Kiwi::View
    v_attribute :name,  String
    v_attribute :gender, String, :optional => true

    v_attribute :attributes, :collection => true, :optional => true do |sub|
      sub.v_attribute :awesome, Boolean, :default => false, :optional => true
      sub.v_attribute :awake,   Boolean, :default => false
    end
  end


  class CatValidator < Kiwi::View
    string  :name
    integer :age
    string  :colors, :collection => true
  end


  def test_v_attribute_name
    v_attribute = PersonValidator.v_attributes[:name]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal false,                 v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_v_attribute_gender
    v_attribute = PersonValidator.v_attributes[:gender]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end



  def test_v_attribute_attributes
    v_attribute = PersonValidator.v_attributes[:attributes]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert       v_attribute.type.is_a?(Kiwi::Validator)

    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default

    sub_attribute = v_attribute.type.v_attributes[:awesome]
    assert_equal Kiwi::Validator::Attribute, sub_attribute.class
    assert_equal false,                 sub_attribute.collection
    assert_equal true,                  sub_attribute.optional
    assert_equal false,                 sub_attribute.default

    sub_attribute = v_attribute.type.v_attributes[:awake]
    assert_equal Kiwi::Validator::Attribute, sub_attribute.class
    assert_equal false,                 sub_attribute.collection
    assert_equal false,                 sub_attribute.optional
    assert_equal false,                 sub_attribute.default
  end


  def test_string_attribute
    PersonValidator.string :foo, :optional => true
    v_attribute = PersonValidator.v_attributes[:foo]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal String,                v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_integer_attribute
    PersonValidator.integer :foo, :optional => true
    v_attribute = PersonValidator.v_attributes[:foo]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal Integer,               v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_boolean_attribute
    PersonValidator.boolean :foo, :optional => true
    v_attribute = PersonValidator.v_attributes[:foo]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal Boolean,               v_attribute.type
    assert_equal false,                 v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_validator_attribute
    PersonValidator.validator :cats, CatValidator,
      :optional => true, :collection => true

    v_attribute = PersonValidator.v_attributes[:cats]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert_equal CatValidator,               v_attribute.type
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_collection_attribute
    PersonValidator.collection :cats, :optional => true do |cat|
      cat.string  :name
      cat.integer :age
    end

    v_attribute = PersonValidator.v_attributes[:cats]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert       v_attribute.type.is_a?(Kiwi::Validator)
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_subset_attribute
    PersonValidator.collection :cats, :optional => true do |cat|
      cat.string  :name
      cat.integer :age
    end

    v_attribute = PersonValidator.v_attributes[:cats]

    assert_equal Kiwi::Validator::Attribute, v_attribute.class
    assert       v_attribute.type.is_a?(Kiwi::Validator)
    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default
  end


  def test_build_basic
    res = PersonValidator.build :name => "John"
    expected = {"name" => "John"}

    assert_equal expected, res
  end


  def test_build_basic_subs
    res = PersonValidator.build :name => "John",
                                :attributes => [{:awake => true}]

    expected = {"name" => "John",
        "attributes" => [{"awake" => true, "awesome" => false}]}

    assert_equal expected, res
  end


  def test_build_wrong_type
    assert_raises Kiwi::InvalidTypeError do
      PersonValidator.build :name => 123
    end

    assert_raises Kiwi::InvalidTypeError do
      PersonValidator.build :name => "John", :attributes => [{:awake => 'foo'}]
    end
  end


  def test_to_hash_basic
    res = PersonValidator.new(:name => "John").to_hash
    expected = {"name" => "John"}

    assert_equal expected, res
  end


  def test_to_hash_basic_subs
    res = PersonValidator.
      new(:name => "John", :attributes => [{:awake => true}]).to_hash

    expected = {"name" => "John",
        "attributes" => [{"awake" => true, "awesome" => false}]}

    assert_equal expected, res
  end


  def test_to_hash_wrong_type
    assert_raises Kiwi::InvalidTypeError do
      PersonValidator.new(:name => 123).to_hash
    end

    assert_raises Kiwi::InvalidTypeError do
      PersonValidator.
        new(:name => "John", :attributes => [{:awake => 'foo'}]).to_hash
    end
  end


  def test_to_a_validator
    PersonValidator.validator :cats, CatValidator,
      :optional => true, :collection => true

    expected = [
 {:name=>"_type", :type=>"String", :optional=>true},
 {:name=>"_links",
  :type=>"Kiwi::Resource::Link",
  :collection=>true,
  :optional=>true},
 {:name=>"name", :type=>"String"},
 {:name=>"gender", :type=>"String", :optional=>true},
 {:name=>"attributes",
  :attributes=>
   [{:name=>"_type", :type=>"String", :optional=>true},
    {:name=>"_links",
     :type=>"Kiwi::Resource::Link",
     :collection=>true,
     :optional=>true},
    {:name=>"awesome", :type=>"Boolean", :default=>"false", :optional=>true},
    {:name=>"awake", :type=>"Boolean", :default=>"false"}],
  :type=>"_embedded",
  :collection=>true,
  :optional=>true},
 {:name=>"foo", :type=>"String", :optional=>true},
 {:name=>"cats",
  :attributes=>
   [{:name=>"_type", :type=>"String", :optional=>true},
    {:name=>"_links",
     :type=>"Kiwi::Resource::Link",
     :collection=>true,
     :optional=>true},
    {:name=>"name", :type=>"String"},
    {:name=>"age", :type=>"Integer"},
    {:name=>"colors", :type=>"String", :collection=>true}],
  :type=>"_embedded",
  :collection=>true,
  :optional=>true}
    ]

    assert_equal expected, PersonValidator.to_a
  end


  def test_to_a_resource
    PersonValidator.validator :cats, FooResource,
      :optional => true, :collection => true

    expected = [
 {:name=>"_type", :type=>"String", :optional=>true},
 {:name=>"_links",
  :type=>"Kiwi::Resource::Link",
  :collection=>true,
  :optional=>true},
 {:name=>"name", :type=>"String"},
 {:name=>"gender", :type=>"String", :optional=>true},
 {:name=>"attributes",
  :attributes=>
   [{:name=>"_type", :type=>"String", :optional=>true},
    {:name=>"_links",
     :type=>"Kiwi::Resource::Link",
     :collection=>true,
     :optional=>true},
    {:name=>"awesome", :type=>"Boolean", :default=>"false", :optional=>true},
    {:name=>"awake", :type=>"Boolean", :default=>"false"}],
  :type=>"_embedded",
  :collection=>true,
  :optional=>true},
 {:name=>"foo", :type=>"String", :optional=>true},
 {:name=>"cats", :type=>"FooResource", :collection=>true, :optional=>true}
    ]

    assert_equal expected, PersonValidator.to_a
  end
end
