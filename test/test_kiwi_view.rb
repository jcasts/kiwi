require 'test/helper'

class TestKiwiView < Test::Unit::TestCase

  class PersonView < Kiwi::View
    v_attribute :name, String
    v_attribute :gender, String, :optional => true

    v_attribute :attributes, :collection => true, :optional => true do |sub|
      sub.v_attribute :awesome, Boolean, :default => false, :optional => true
      sub.v_attribute :awake, Boolean, :default => false
    end
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
    assert       v_attribute.type.ancestors.include?(PersonView)

    assert_equal true,                  v_attribute.collection
    assert_equal true,                  v_attribute.optional
    assert_nil                          v_attribute.default

    sub_attribute = v_attribute.type.v_attributes['awesome']
    assert_equal Kiwi::View::Attribute, sub_attribute.class
    assert_equal false,                 sub_attribute.collection
    assert_equal true,                  sub_attribute.optional
    assert_equal false,                 sub_attribute.default
  end
end
