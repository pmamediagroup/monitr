require File.dirname(__FILE__) + '/helper'

class TestRegistry < Test::Unit::TestCase
  def setup
    Monitr.registry.reset
  end
  
  def test_add
    foo = Monitr::Process.new
    foo.name = 'foo'
    Monitr.registry.add(foo)
    assert_equal 1, Monitr.registry.size
    assert_equal foo, Monitr.registry['foo']
  end
end