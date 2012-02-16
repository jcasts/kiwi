require 'test/helper'

class TestKiwiViewAttribute < Test::Unit::TestCase

  def setup
    @req_attr         = Kiwi::View::Attribute.new :foo, Integer
    @req_default_attr = Kiwi::View::Attribute.new :foo, Integer,
                          :default => 456

    @opt_attr         = Kiwi::View::Attribute.new :foo, String,
                          :optional => true
    @opt_default_attr = Kiwi::View::Attribute.new :foo, String,
                          :default => "foo", :optional => true

    @view_attr = Kiwi::View::Attribute.new :foo, Kiwi::View

    @bool_attr         = Kiwi::View::Attribute.new :foo, Boolean
    @bool_default_attr = Kiwi::View::Attribute.new :foo, Boolean,
                          :default => false

    @obj_true  = Struct.new(:foo).new true
    @obj_false = Struct.new(:foo).new false
    @str_hash  = {'foo' => "string"}
    @sym_hash  = {:foo  => 123}
  end


  def test_invalid_default
    assert_raises Kiwi::InvalidTypeError, 'Default "Hi" isn\'t a Integer' do
      Kiwi::View::Attribute.new :foo, Integer, :default => "Hi"
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


  def test_opt_attr
    assert_equal "string", @opt_attr.value_from(@str_hash)
    assert_nil @opt_attr.value_from(Struct.new(:blah).new(123))

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


  def test_view_attr
    # TODO: Implement
    skip
  end
end
