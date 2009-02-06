require File.dirname(__FILE__) + '/helper'

class TestMonitr < Test::Unit::TestCase
  def setup
    Monitr::Socket.stubs(:new).returns(true)
    Monitr.stubs(:setup).returns(true)
    Monitr.stubs(:validater).returns(true)
    Thread.any_instance.stubs(:join).returns(true)
    Monitr.reset
    Monitr.pid_file_directory = '/var/run/monitr'
  end
  
  def teardown
    Monitr.main && Monitr.main.kill
    if Monitr.watches
      Monitr.watches.each do |k, w|
        w.driver.thread.kill
      end
    end
  end
  
  # applog
  
  def test_applog
    LOG.expects(:log).with(nil, :debug, 'foo')
    applog(nil, :debug, 'foo')
  end
  
  # internal_init
  
  def test_init_should_initialize_watches_to_empty_array
    Monitr.internal_init { }
    assert_equal Hash.new, Monitr.watches
  end
  
  # init
  
  def test_pid_file_directory_should_abort_if_called_after_watch
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    assert_abort do
      Monitr.pid_file_directory = 'foo'
    end
  end
  
  # pid_file_directory
  
  def test_pid_file_directory_should_return_default_if_not_set_explicitly
    Monitr.internal_init
    assert_equal '/var/run/monitr', Monitr.pid_file_directory
  end
  
  def test_pid_file_directory_equals_should_set
    Monitr.pid_file_directory = '/foo'
    Monitr.internal_init
    assert_equal '/foo', Monitr.pid_file_directory
  end
  
  # watch
  
  def test_watch_should_get_stored
    watch = nil
    Monitr.watch do |w|
      w.name = 'foo'
      w.start = 'bar'
      watch = w
    end
    
    assert_equal 1, Monitr.watches.size
    assert_equal watch, Monitr.watches.values.first
    
    assert_equal 0, Monitr.groups.size
  end
  
  def test_watch_should_get_stored_in_pending_watches
    watch = nil
    Monitr.watch do |w|
      w.name = 'foo'
      w.start = 'bar'
      watch = w
    end
    
    assert_equal 1, Monitr.pending_watches.size
    assert_equal watch, Monitr.pending_watches.first
  end
  
  def test_watch_should_register_processes
    assert_nil Monitr.registry['foo']
    Monitr.watch do |w|
      w.name = 'foo'
      w.start = 'bar'
    end
    assert_kind_of Monitr::Process, Monitr.registry['foo']
  end
  
  def test_watch_should_get_stored_by_group
    a = nil
    
    Monitr.watch do |w|
      a = w
      w.name = 'foo'
      w.start = 'bar'
      w.group = 'test'
    end
    
    assert_equal({'test' => [a]}, Monitr.groups)
  end
  
  def test_watches_should_get_stored_by_group
    a = nil
    b = nil
    
    Monitr.watch do |w|
      a = w
      w.name = 'foo'
      w.start = 'bar'
      w.group = 'test'
    end
    
    Monitr.watch do |w|
      b = w
      w.name = 'bar'
      w.start = 'baz'
      w.group = 'test'
    end
    
    assert_equal({'test' => [a, b]}, Monitr.groups)
  end
      
  def test_watch_should_allow_multiple_watches
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    assert_nothing_raised do
      Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    end
  end
  
  def test_watch_should_disallow_duplicate_watch_names
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    assert_abort do
      Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    end
  end
  
  def test_watch_should_disallow_identical_watch_and_group_names
    Monitr.watch { |w| w.name = 'foo'; w.group = 'bar'; w.start = 'bar' }
    
    assert_abort do
      Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    end
  end
  
  def test_watch_should_disallow_identical_watch_and_group_names_other_way
    Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    
    assert_abort do
      Monitr.watch { |w| w.name = 'foo'; w.group = 'bar'; w.start = 'bar' }
    end
  end
  
  def test_watch_should_unwatch_new_watch_if_running_and_duplicate_watch
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    Monitr.running = true
    
    assert_nothing_raised do
      no_stdout do
        Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
      end
    end
  end
  
  # unwatch
  
  def test_unwatch_should_unmonitor_watch
    Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    w = Monitr.watches['bar']
    w.state = :up
    w.expects(:unmonitor)
    no_stdout do
      Monitr.unwatch(w)
    end
  end
  
  def test_unwatch_should_unregister_watch
    Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    w = Monitr.watches['bar']
    w.expects(:unregister!)
    no_stdout do
      Monitr.unwatch(w)
    end
  end
  
  def test_unwatch_should_remove_same_name_watches
    Monitr.watch { |w| w.name = 'bar'; w.start = 'bar' }
    w = Monitr.watches['bar']
    no_stdout do
      Monitr.unwatch(w)
    end
    assert_equal 0, Monitr.watches.size
  end
  
  def test_unwatch_should_remove_from_group
    Monitr.watch do |w|
      w.name = 'bar'
      w.start = 'baz'
      w.group = 'test'
    end
    w = Monitr.watches['bar']
    no_stdout do
      Monitr.unwatch(w)
    end
    assert !Monitr.groups[w.group].include?(w)
  end
  
  # contact
  
  def test_contact_should_ensure_init_is_called
    Monitr.contact(:fake_contact) { |c| c.name = 'tom' }
    assert Monitr.inited
  end
  
  def test_contact_should_abort_on_invalid_contact_kind
    assert_abort do
      Monitr.contact(:foo) { |c| c.name = 'tom' }
    end
  end
  
  def test_contact_should_create_and_store_contact
    contact = nil
    Monitr.contact(:fake_contact) { |c| c.name = 'tom'; contact = c }
    assert [contact], Monitr.contacts
  end
  
  def test_contact_should_add_to_group
    Monitr.contact(:fake_contact) { |c| c.name = 'tom'; c.group = 'devs' }
    Monitr.contact(:fake_contact) { |c| c.name = 'chris'; c.group = 'devs' }
    assert 2, Monitr.contact_groups.size
  end
  
  def test_contact_should_abort_on_no_name
    no_stdout do
      assert_abort do
        Monitr.contact(:fake_contact) { |c| }
      end
    end
  end
  
  def test_contact_should_abort_on_duplicate_contact_name
    Monitr.contact(:fake_contact) { |c| c.name = 'tom' }
    no_stdout do
      assert_nothing_raised do
        Monitr.contact(:fake_contact) { |c| c.name = 'tom' }
      end
    end
  end
  
  def test_contact_should_abort_on_contact_with_same_name_as_group
    Monitr.contact(:fake_contact) { |c| c.name = 'tom'; c.group = 'devs' }
    no_stdout do
      assert_nothing_raised do
        Monitr.contact(:fake_contact) { |c| c.name = 'devs' }
      end
    end
  end
  
  def test_contact_should_abort_on_contact_with_same_group_as_name
    Monitr.contact(:fake_contact) { |c| c.name = 'tom' }
    assert_abort do
      Monitr.contact(:fake_contact) { |c| c.name = 'chris'; c.group = 'tom' }
    end
  end
  
  def test_contact_should_abort_if_contact_is_invalid
    assert_abort do
      Monitr.contact(:fake_contact) do |c|
        c.name = 'tom'
        c.stubs(:valid?).returns(false)
      end
    end
  end
  
  # control
  
  def test_control_should_monitor_on_start
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.expects(:monitor)
    Monitr.control('foo', 'start')
  end
  
  def test_control_should_move_to_restart_on_restart
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.expects(:move).with(:restart)
    Monitr.control('foo', 'restart')
  end
  
  def test_control_should_unmonitor_and_stop_on_stop
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.state = :up
    w.expects(:unmonitor).returns(w)
    w.expects(:action).with(:stop)
    Monitr.control('foo', 'stop')
  end
  
  def test_control_should_unmonitor_on_unmonitor
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.state = :up
    w.expects(:unmonitor).returns(w)
    Monitr.control('foo', 'unmonitor')
  end
  
  def test_control_should_unwatch_on_remove
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.state = :up
    Monitr.expects(:unwatch)
    Monitr.control('foo', 'remove')
  end
  
  def test_control_should_raise_on_invalid_command
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    assert_raise InvalidCommandError do
      Monitr.control('foo', 'invalid')
    end
  end
  
  def test_control_should_operate_on_each_watch_in_group
    Monitr.watch do |w|
      w.name = 'foo1'
      w.start = 'go'
      w.group = 'bar'
    end
    
    Monitr.watch do |w|
      w.name = 'foo2'
      w.start = 'go'
      w.group = 'bar'
    end
    
    Monitr.watches['foo1'].expects(:monitor)
    Monitr.watches['foo2'].expects(:monitor)
    
    Monitr.control('bar', 'start')
  end
  
  # stop_all
  
  # terminate
  
  def test_terminate_should_exit
    Monitr.pid = nil
    FileUtils.expects(:rm_f).never
    Monitr.expects(:exit!)
    Monitr.terminate
  end
  
  def test_terminate_should_delete_pid
    Monitr.pid = '/foo/bar'
    FileUtils.expects(:rm_f).with("/foo/bar")
    Monitr.expects(:exit!)
    Monitr.terminate
  end
  
  # status
  
  def test_status_should_show_state
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    w.state = :up
    assert_equal({'foo' => {:state => :up, :group => nil}}, Monitr.status)
  end
  
  def test_status_should_show_state_with_group
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar'; w.group = 'g' }
    
    w = Monitr.watches['foo']
    w.state = :up
    assert_equal({'foo' => {:state => :up, :group => 'g'}}, Monitr.status)
  end

  def test_status_should_show_unmonitored_for_nil_state
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    
    w = Monitr.watches['foo']
    assert_equal({'foo' => {:state => :unmonitored, :group => nil}}, Monitr.status)
  end
  
  # running_log
  
  def test_running_log_should_call_watch_log_since_on_main_log
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    t = Time.now
    LOG.expects(:watch_log_since).with('foo', t)
    Monitr.running_log('foo', t)
  end
  
  def test_running_log_should_raise_on_unknown_watch
    Monitr.internal_init
    assert_raise(NoSuchWatchError) do
      Monitr.running_log('foo', Time.now)
    end
  end
  
  # running_load
  
  def test_running_load_should_eval_code
    code = <<-EOF
      Monitr.watch do |w|
        w.name = 'foo'
        w.start = 'go'
      end
    EOF
    
    no_stdout do
      Monitr.running_load(code, '/foo/bar.monitr')
    end
    
    assert_equal 1, Monitr.watches.size
  end
  
  def test_running_load_should_monitor_new_watches
    code = <<-EOF
      Monitr.watch do |w|
        w.name = 'foo'
        w.start = 'go'
      end
    EOF
    
    Watch.any_instance.expects(:monitor)
    no_stdout do
      Monitr.running_load(code, '/foo/bar.monitr')
    end
  end
  
  def test_running_load_should_not_monitor_new_watches_with_autostart_false
    code = <<-EOF
      Monitr.watch do |w|
        w.name = 'foo'
        w.start = 'go'
        w.autostart = false
      end
    EOF
    
    Watch.any_instance.expects(:monitor).never
    no_stdout do
      Monitr.running_load(code, '/foo/bar.monitr')
    end
  end
  
  def test_running_load_should_return_array_of_affected_watches
    code = <<-EOF
      Monitr.watch do |w|
        w.name = 'foo'
        w.start = 'go'
      end
    EOF
    
    w = nil
    no_stdout do
      w, e = *Monitr.running_load(code, '/foo/bar.monitr')
    end
    assert_equal 1, w.size
    assert_equal 'foo', w.first
  end
  
  def test_running_load_should_clear_pending_watches
    code = <<-EOF
      Monitr.watch do |w|
        w.name = 'foo'
        w.start = 'go'
      end
    EOF
    
    no_stdout do
      Monitr.running_load(code, '/foo/bar.monitr')
    end
    assert_equal 0, Monitr.pending_watches.size
  end
  
  # load
  
  def test_load_should_collect_and_load_globbed_path
    Dir.expects(:[]).with('/path/to/*.thing').returns(['a', 'b'])
    Kernel.expects(:load).with('a').once
    Kernel.expects(:load).with('b').once
    Monitr.load('/path/to/*.thing')
  end
  
  # start
  
  def test_start_should_kick_off_a_server_instance
    Monitr::Socket.expects(:new).returns(true)
    Monitr.start
  end
  
  def test_start_should_begin_monitoring_autostart_watches
    Monitr.watch do |w|
      w.name = 'foo'
      w.start = 'go'
    end
    
    Watch.any_instance.expects(:monitor).once
    Monitr.start
  end
  
  def test_start_should_not_begin_monitoring_non_autostart_watches
    Monitr.watch do |w|
      w.name = 'foo'
      w.start = 'go'
      w.autostart = false
    end
    
    Watch.any_instance.expects(:monitor).never
    Monitr.start
  end
  
  def test_start_should_get_and_join_timer
    Monitr.watch { |w| w.name = 'foo'; w.start = 'bar' }
    no_stdout do
      Monitr.start
    end
  end
  
  # at_exit
  
  def test_at_exit_should_call_start
    Monitr.expects(:start).once
    Monitr.at_exit
  end
  
  # pattern_match
  
  def test_pattern_match
    list = %w{ mongrel-3000 mongrel-3001 fuzed fuzed2 apache mysql}
    
    assert_equal %w{ mongrel-3000 }, Monitr.pattern_match('m3000', list)
    assert_equal %w{ mongrel-3001 }, Monitr.pattern_match('m31', list)
    assert_equal %w{ fuzed fuzed2 }, Monitr.pattern_match('fu', list)
    assert_equal %w{ mysql }, Monitr.pattern_match('sql', list)
  end
end


# class TestMonitrOther < Test::Unit::TestCase
#   def setup
#     Monitr::Socket.stubs(:new).returns(true)
#     Monitr.internal_init
#     Monitr.reset
#   end
#   
#   def teardown
#     Monitr.main && Monitr.main.kill
#   end
#   
#   # setup
#   
#   def test_setup_should_create_pid_file_directory_if_it_doesnt_exist
#     Monitr.expects(:test).returns(false)
#     FileUtils.expects(:mkdir_p).with(Monitr.pid_file_directory)
#     Monitr.setup
#   end
#   
#   def test_setup_should_raise_if_no_permissions_to_create_pid_file_directory
#     Monitr.expects(:test).returns(false)
#     FileUtils.expects(:mkdir_p).raises(Errno::EACCES)
#     
#     assert_abort do
#       Monitr.setup
#     end
#   end
#   
#   # validate
#     
#   def test_validate_should_abort_if_pid_file_directory_is_unwriteable
#     Monitr.expects(:test).returns(false)
#     assert_abort do
#       Monitr.validater
#     end
#   end
#   
#   def test_validate_should_not_abort_if_pid_file_directory_is_writeable
#     Monitr.expects(:test).returns(true)
#     assert_nothing_raised do
#       Monitr.validater
#     end
#   end
# end
