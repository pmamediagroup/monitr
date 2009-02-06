module Monitr
  module CLI
    
    class Command
      def initialize(command, options, args)
        @command = command
        @options = options
        @args = args
        
        dispatch
      end
      
      def setup
        # connect to drb unix socket
        DRb.start_service("druby://127.0.0.1:0")
        @server = DRbObject.new(nil, Monitr::Socket.socket(@options[:port]))
        
        # ping server to ensure that it is responsive
        begin
          @server.ping
        rescue DRb::DRbConnError
          puts "The server is not available (or you do not have permissions to access it)"
          abort
        end
      end
      
      def dispatch
        if %w{load status signal log quit terminate}.include?(@command)
          setup
          send("#{@command}_command")
        elsif %w{start stop restart monitor unmonitor remove}.include?(@command)
          setup
          lifecycle_command
        elsif @command == 'check'
          check_command
        else
          puts "Command '#{@command}' is not valid. Run 'monitr --help' for usage"
          abort
        end
      end
      
      def load_command
        file = @args[1]
          
        puts "Sending '#{@command}' command"
        puts
        
        unless File.exist?(file)
          abort "File not found: #{file}"
        end
        
        names, errors = *@server.running_load(File.read(file), File.expand_path(file))
        
        # output response
        unless names.empty?
          puts 'The following tasks were affected:'
          names.each do |w|
            puts '  ' + w
          end
        end
        
        unless errors.empty?
          puts errors
          exit(1)
        end
      end
      
      def status_command
        watches = {}
        @server.status.each do |name, status|
          g = status[:group] || ''
          unless watches.has_key?(g)
            watches[g] = {}
          end
          watches[g][name] = status
        end
        watches.keys.sort.each do |group|
          puts "#{group}:" unless group.empty?
          watches[group].keys.sort.each do |name|
            state = watches[group][name][:state]
            print "  " unless group.empty?
            puts "#{name}: #{state}"
          end
        end
      end
      
      def signal_command
        # get the name of the watch/group
        name = @args[1]
        signal = @args[2]
        
        puts "Sending signal '#{signal}' to '#{name}'"
        
        t = Thread.new { loop { sleep(1); STDOUT.print('.'); STDOUT.flush; sleep(1) } }
        
        watches = @server.signal(name, signal)
        
        # output response
        t.kill; STDOUT.puts
        unless watches.empty?
          puts 'The following watches were affected:'
          watches.each do |w|
            puts '  ' + w
          end
        else
          puts 'No matching task or group'
        end
      end
      
      def log_command
        begin
          Signal.trap('INT') { exit }
          name = @args[1]
          
          unless name
            puts "You must specify a Task or Group name"
            exit!
          end
          
          t = Time.at(0)
          loop do
            print @server.running_log(name, t)
            t = Time.now
            sleep 1
          end
        rescue Monitr::NoSuchWatchError
          puts "No such watch"
        rescue DRb::DRbConnError
          puts "The server went away"
        end
      end
      
      def quit_command
        begin
          @server.terminate
          abort 'Could not stop monitr'
        rescue DRb::DRbConnError
          puts 'Stopped monitr'
        end
      end
      
      def terminate_command
        t = Thread.new { loop { STDOUT.print('.'); STDOUT.flush; sleep(1) } }
        if @server.stop_all
          t.kill; STDOUT.puts
          puts 'Stopped all watches'
        else
          t.kill; STDOUT.puts
          puts 'Could not stop all watches within 10 seconds'
        end
        
        begin
          @server.terminate
          abort 'Could not stop monitr'
        rescue DRb::DRbConnError
          puts 'Stopped monitr'
        end
      end
      
      def check_command
        Thread.new do
          begin
            event_system = Monitr::EventHandler.event_system
            puts "using event system: #{event_system}"
            
            if Monitr::EventHandler.loaded?
              puts "starting event handler"
              Monitr::EventHandler.start
            else
              puts "[fail] event system did not load"
              exit(1)
            end
            
            puts 'forking off new process'
            
            pid = fork do
              loop { sleep(1) }
            end
            
            puts "forked process with pid = #{pid}"
            
            Monitr::EventHandler.register(pid, :proc_exit) do
              puts "[ok] process exit event received"
              exit!(0)
            end
            
            sleep(1)
            
            puts "killing process"
            
            ::Process.kill('KILL', pid)
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
          end
        end
        
        sleep(2)
        
        puts "[fail] never received process exit event"
        exit(1)
      end
      
      def lifecycle_command
        # get the name of the watch/group
        name = @args[1]
        
        puts "Sending '#{@command}' command"
        
        t = Thread.new { loop { sleep(1); STDOUT.print('.'); STDOUT.flush; sleep(1) } }
        
        # send @command
        watches = @server.control(name, @command)
        
        # output response
        t.kill; STDOUT.puts
        unless watches.empty?
          puts 'The following watches were affected:'
          watches.each do |w|
            puts '  ' + w
          end
        else
          puts 'No matching task or group'
        end
      end
    end # Command
    
  end
end
