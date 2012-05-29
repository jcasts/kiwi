require 'test/helper'

class TestKiwiResource < Test::Unit::TestCase
  class Foo < Kiwi::Resource; end

  def test_init
    assert_equal "/test_kiwi_resource/foo", Foo.route
    assert_equal :id, Foo.identifier

    assert_equal 1, Foo.redirects.length
    assert_equal :get, Foo.redirects[:options][:method]
    assert_equal Kiwi::Resource::Resource, Foo.redirects[:options][:resource]
    assert_equal Proc, Foo.redirects[:options][:proc].class
  end
end
