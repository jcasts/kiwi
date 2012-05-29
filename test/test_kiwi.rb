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
    assert_nil Kiwi.find_const(["Foo", "Bar"])
    assert_nil Kiwi.find_const("Foo::Bar")
  end
end
