require File.dirname(__FILE__) + '/helper'

class TestSocket < Test::Unit::TestCase
  def setup
    silence_warnings do 
      Object.const_set(:DRb, stub_everything)
    end
  end

  def test_should_start_a_drb_server
    DRb.expects(:start_service)
    no_stdout do
      Monitr::Socket.new
    end
  end

  def test_should_use_supplied_port_and_host
    DRb.expects(:start_service).with { |uri, object| uri == "drbunix:///tmp/monitr.9999.sock" && object.is_a?(Monitr::Socket) }
    no_stdout do
      server = Monitr::Socket.new(9999)
    end
  end

  def test_should_forward_foreign_method_calls_to_monitr
    server = nil
    no_stdout do
      server = Monitr::Socket.new
    end
    Monitr.expects(:send).with(:something_random)
    server.something_random
  end
  
  # ping
  
  def test_ping_should_return_true
    server = nil
    no_stdout do
      server = Monitr::Socket.new
    end
    assert server.ping
  end
end
