require File.dirname(__FILE__) + '/helper'

class TestEmail < Test::Unit::TestCase
  def test_exists
    Monitr::Contacts::Email
  end

  def test_unknown_delivery_method_for_notify
    assert_nothing_raised do
      Monitr::Contacts::Email.any_instance.expects(:notify_smtp).never
      Monitr::Contacts::Email.any_instance.expects(:notify_sendmail).never
      Monitr::Contacts::Email.delivery_method = :foo_protocol
      LOG.expects(:log).times(2)
 
      g = Monitr::Contacts::Email.new
      g.notify(:a, :b, :c, :d, :e)
      assert_nil g.info
    end
  end

  def test_smtp_delivery_method_for_notify
    assert_nothing_raised do
      Monitr::Contacts::Email.any_instance.expects(:notify_sendmail).never
      Monitr::Contacts::Email.any_instance.expects(:notify_smtp).once.returns(nil)
      Monitr::Contacts::Email.delivery_method = :smtp
      g = Monitr::Contacts::Email.new
      g.email = 'joe@example.com'
      g.notify(:a, :b, :c, :d, :e)
      assert_equal "sent email to joe@example.com", g.info
    end
  end
  
  def test_sendmail_delivery_method_for_notify
    assert_nothing_raised do
      Monitr::Contacts::Email.any_instance.expects(:notify_smtp).never
      Monitr::Contacts::Email.any_instance.expects(:notify_sendmail).once.returns(nil)
      Monitr::Contacts::Email.delivery_method = :sendmail
      g = Monitr::Contacts::Email.new
      g.email = 'joe@example.com'
      g.notify(:a, :b, :c, :d, :e)
      assert_equal "sent email to joe@example.com", g.info
    end
  end
  
end
