require 'test/helper'

class TestKiwi < Test::Unit::TestCase

  def test_find_const_empty
    assert_equal Object, Kiwi.find_const([])
    assert_equal Object, Kiwi.find_const("")
  end


  def test_find_const_single
    assert_equal String, Kiwi.find_const(["String"])
    assert_equal String, Kiwi.find_const("String")
  end


  def test_find_const_deep
    assert_equal Test::Unit::TestCase,
      Kiwi.find_const(["Test", "Unit", "TestCase"])

    assert_equal Test::Unit::TestCase,
      Kiwi.find_const("Test::Unit::TestCase")
  end


  def test_find_const_non_existant
    assert_raises(NameError, "uninitialized constant Foo") do
      Kiwi.find_const(["Foo", "Bar"])
    end

    assert_raises(NameError, "uninitialized constant Foo") do
      Kiwi.find_const("Foo::Bar")
    end
  end


  def test_assign_const_empty
    assert_raises(NoMethodError, "undefined method `capitalize' for nil:NilClass") do
      Kiwi.assign_const "", "foo"
    end
  end


  def test_assign_const_one
    Kiwi.assign_const "Bar", "bar"
    assert_equal ::Bar, "bar"

    Kiwi.assign_const "Bar", "foobar"
    assert_equal ::Bar, "foobar"
  end


  def test_assign_const_deep
    Kiwi.assign_const "TestKiwi::Bar", "test_bar"
    assert_equal Bar, "test_bar"

    Kiwi.assign_const "TestKiwi::Bar", "test_foobar"
    assert_equal Bar, "test_foobar"
  end


  def test_assign_const_deep_nonexistant
    assert_raises NameError, "uninitialized constant TestKiwi::Foo" do
      Kiwi.assign_const "TestKiwi::Foo::Bar", "test_bar"
    end
  end
end
