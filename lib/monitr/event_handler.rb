module Monitr
  class EventHandler
    @@actions = {}
    @@handler = nil
    @@loaded = false
    
    def self.loaded?
      @@loaded
    end
    
    def self.event_system
      @@handler::EVENT_SYSTEM
    end
    
    def self.load
      begin
        case RUBY_PLATFORM
        when /darwin/i, /bsd/i
          require 'monitr/event_handlers/kqueue_handler'
          @@handler = KQueueHandler
        when /linux/i
          require 'monitr/event_handlers/netlink_handler'
          @@handler = NetlinkHandler
        else
          raise NotImplementedError, "Platform not supported for EventHandler"
        end
        @@loaded = true
      rescue Exception
        require 'monitr/event_handlers/dummy_handler'
        @@handler = DummyHandler
        @@loaded = false
      end
    end
    
    def self.register(pid, event, &block)
      @@actions[pid] ||= {}
      @@actions[pid][event] = block
      @@handler.register_process(pid, @@actions[pid].keys)
    end
    
    def self.deregister(pid, event=nil)
      if watching_pid? pid
        running = ::Process.kill(0, pid.to_i) rescue false
        if event.nil?
          @@actions.delete(pid)
          @@handler.register_process(pid, []) if running
        else
          @@actions[pid].delete(event)
          @@handler.register_process(pid, @@actions[pid].keys) if running
        end
      end
    end
    
    def self.call(pid, event, extra_data = {})
      @@actions[pid][event].call(extra_data) if watching_pid?(pid) && @@actions[pid][event]
    end
    
    def self.watching_pid?(pid)
      @@actions[pid]
    end
    
    def self.start
      Thread.new do
        loop do
          begin
            @@handler.handle_events
          rescue Exception => e
            message = format("Unhandled exception (%s): %s\n%s",
                             e.class, e.message, e.backtrace.join("\n"))
            applog(nil, :fatal, message)
          end
        end
      end
      
      # do a real test to make sure events are working properly
      @@loaded = self.operational?
    end
    
    def self.operational?
      com = [false]
      
      Thread.new do
        begin
          event_system = Monitr::EventHandler.event_system
          
          pid = fork do
            loop { sleep(1) }
          end
          
          self.register(pid, :proc_exit) do
            com[0] = true
          end
          
          ::Process.kill('KILL', pid)
          
          sleep(0.1)
          
          self.deregister(pid, :proc_exit) rescue nil
        rescue => e
          puts e.message
          puts e.backtrace.join("\n")
        end
      end.join
      
      sleep(0.1)
      
      com.first
    end
    
  end
end