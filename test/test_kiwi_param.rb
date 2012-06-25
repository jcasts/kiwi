require 'test/helper'

class TestKiwiParam < Test::Unit::TestCase

  def setup
    @param_foo = Kiwi::Param.new "foo", Integer,
              :except => :bar, :only => [:blah, :bar]

    @param_bar = Kiwi::Param.new "bar", String

    @param_baz = Kiwi::Param.new "baz", Boolean

    @param_flt = Kiwi::Param.new "flt", Float
  end


  def test_init
    assert @param_foo.is_a?(Kiwi::Validator::Attribute),
      "Param should inherit Kiwi::Validator::Attribute"

    assert_equal [:bar],        @param_foo.except
    assert_equal [:blah, :bar], @param_foo.only
    assert_equal :foo,          @param_foo.name
    assert_equal Integer,       @param_foo.type
  end


  def test_include
    assert @param_foo.include?(:blah), "@param should include method :blah"
    assert !@param_foo.include?(:bad), "@param should not include method :bad"
    assert !@param_foo.include?(:bar), "@param should not include method :bar"

    assert @param_bar.include?(:foo), "@param should include any method"
  end


  def test_coerce
    assert_equal "foo", @param_bar.coerce("foo")
    assert_equal "foo", @param_bar.coerce(:foo)
    assert_equal 123,   @param_foo.coerce("123")
    assert_equal 123.0, @param_flt.coerce("123")
    assert_equal 123.1, @param_flt.coerce("123.10")
  end


  def test_coerce_bool
    assert_equal true,  @param_baz.coerce("1234")
    assert_equal true,  @param_baz.coerce("T")
    assert_equal true,  @param_baz.coerce("true")
    assert_equal true,  @param_baz.coerce("yes")
    assert_equal true,  @param_baz.coerce("1")
    assert_equal true,  @param_baz.coerce("Y")

    assert_equal false,  @param_baz.coerce("false")
    assert_equal false,  @param_baz.coerce("F")
    assert_equal false,  @param_baz.coerce("N")
    assert_equal false,  @param_baz.coerce("0")
    assert_equal false,  @param_baz.coerce("no")
  end


  def test_value_from
    assert_equal true,  @param_baz.value_from(:baz => "foobar")
    assert_equal false, @param_baz.value_from(:baz => "false")
    assert_equal 123,   @param_foo.value_from("foo" => "123")
    assert_equal 123.1, @param_flt.value_from(:flt => "123.10")
  end
end
