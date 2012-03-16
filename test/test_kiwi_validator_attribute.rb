require 'test/helper'

class TestKiwiValidatorAttribute < Test::Unit::TestCase

  def setup
    @req_attr         = Kiwi::Validator::Attribute.new :foo, Integer
    @req_default_attr = Kiwi::Validator::Attribute.new :foo, Integer,
                          :default => 456
    @req_coll_attr    = Kiwi::Validator::Attribute.new :foo, Integer,
                          :collection => true

    @opt_attr         = Kiwi::Validator::Attribute.new :foo, String,
                          :optional => true
    @opt_default_attr = Kiwi::Validator::Attribute.new :foo, String,
                          :default => "foo", :optional => true

    @validator_attr      = Kiwi::Validator::Attribute.new :foo, Kiwi::Validator
    @validator_coll_attr = Kiwi::Validator::Attribute.new :foo, Kiwi::Validator,
                        :collection => true

    @bool_attr         = Kiwi::Validator::Attribute.new :foo, Boolean
    @bool_default_attr = Kiwi::Validator::Attribute.new :foo, Boolean,
                          :default => false


    @obj_true  = Struct.new(:foo).new true
    @obj_false = Struct.new(:foo).new false
    @str_hash  = {'foo' => "string"}
    @sym_hash  = {:foo  => 123}
  end


  def test_invalid_default
    assert_raises Kiwi::InvalidTypeError, 'Default "Hi" isn\'t a Integer' do
      Kiwi::Validator::Attribute.new :foo, Integer, :default => "Hi"
    end
  end


  def test_invalid_type
    assert_raises ArgumentError, 'Type nil must be a Class' do
      Kiwi::Validator::Attribute.new :foo, nil
    end
  end


  def test_req_attr
    assert_equal 123, @req_attr.value_from(@sym_hash)

    assert_raises(Kiwi::RequiredValueError) do
      @req_attr.value_from :blah => 123
    end

    assert_raises(Kiwi::RequiredValueError) do
      @req_attr.value_from Struct.new(:blah).new(123)
    end

    assert_raises(Kiwi::InvalidTypeError) do
      @req_attr.value_from Struct.new(:foo).new("test")
    end
  end


  def test_req_default_attr
    assert_equal 123, @req_default_attr.value_from(@sym_hash)
    assert_equal 456, @req_default_attr.value_from(:blah => 123)
    assert_equal 456, @req_default_attr.value_from(Struct.new(:blah).new(123))
  end


  def test_req_coll_attr
    assert_equal [1,2,3], @req_coll_attr.value_from(:foo => [1,2,3])

    assert_raises(Kiwi::InvalidTypeError) do
      @req_coll_attr.value_from(:foo => [1,:bar,3])
    end

    assert_raises(Kiwi::InvalidTypeError, "Collection must respond to `map'") do
      @req_coll_attr.value_from(:foo => 123)
    end

    assert_raises(Kiwi::RequiredValueError) do
      @req_coll_attr.value_from(:bar => 123)
    end
  end


  def test_opt_attr
    assert_equal "string", @opt_attr.value_from(@str_hash)
    assert_nil   @opt_attr.value_from(Struct.new(:blah).new(123))

    assert_raises(Kiwi::InvalidTypeError) do
      @opt_attr.value_from(@sym_hash)
    end
  end


  def test_opt_default_attr
    assert_equal "string", @opt_default_attr.value_from(@str_hash)
    assert_equal "foo", @opt_default_attr.value_from(:blah => 123)
    assert_equal "foo", @opt_default_attr.value_from(Struct.new(:blah).new(123))
  end


  def test_bool_attr
    assert_equal true, @bool_attr.value_from(:foo => true)
    assert_equal false, @bool_attr.value_from(:foo => false)

    assert_raises(Kiwi::InvalidTypeError) do
      @bool_attr.value_from(:foo => nil)
    end

    assert_raises(Kiwi::InvalidTypeError) do
      @bool_attr.value_from(:foo => "blah")
    end

    assert_raises(Kiwi::RequiredValueError) do
      @bool_attr.value_from Struct.new(:blah).new(123)
    end
  end


  def test_bool_default_attr
    assert_equal true, @bool_default_attr.value_from(:foo => true)
    assert_equal false, @bool_default_attr.value_from(:foo => false)

    assert_equal false, @bool_default_attr.value_from(:blah => "foo")

    assert_raises(Kiwi::InvalidTypeError) do
      @bool_default_attr.value_from(:foo => nil)
    end

    assert_raises(Kiwi::InvalidTypeError) do
      @bool_attr.value_from(:foo => "blah")
    end
  end


  def test_later_type
    attrib = Kiwi::Validator::Attribute.new :foo, "Integer"

    assert_equal 123, attrib.value_from(:foo => 123)

    assert_raises(Kiwi::InvalidTypeError) do
      attrib.value_from(:foo => "bar")
    end

    assert_equal Integer, attrib.type
  end


  def test_validator_attr
    validator = Class.new Kiwi::View
    validator.string  :name
    validator.integer :age

    attrib = Kiwi::Validator::Attribute.new 'thing', validator

    val = attrib.value_from :thing => {:name => "George", :age => 34}
    expected = {"name" => "George", "age" => 34}

    assert_equal expected, val
  end
end
