module Monitr
  module CLI
    
    class Run
      def initialize(options)
        @options = options
        
        dispatch
      end
      
      def dispatch
        # have at_exit start monitr
        $run = true
        
        # run
        if @options[:daemonize]
          run_daemonized
        else
          run_in_front
        end
      end
      
      def attach
        process = System::Process.new(@options[:attach])
        Thread.new do
          loop do
            unless process.exists?
              applog(nil, :info, "Going down because attached process #{@options[:attach]} exited")
              exit!
            end
            sleep 5
          end
        end
      end
      
      def default_run
        # make sure we have STDIN/STDOUT redirected immediately
        setup_logging

        # start attached pid watcher if necessary
        if @options[:attach]
          self.attach
        end
        
        if @options[:port]
          Monitr.port = @options[:port]
        end
        
        if @options[:events]
          Monitr::EventHandler.load
        end
        
        # set log level, defaults to WARN
        if @options[:log_level]
          Monitr.log_level = @options[:log_level]
        else
          Monitr.log_level = @options[:daemonize] ? :warn : :info
        end
        
        if @options[:config]
          unless File.exist?(@options[:config])
            abort "File not found: #{@options[:config]}"
          end
          
          # start the event handler
          Monitr::EventHandler.start if Monitr::EventHandler.loaded?
          
          load_config @options[:config]
        end
        setup_logging
      end
      
      def run_in_front
        require 'monitr'
        
        if @options[:bleakhouse]
          BleakHouseDiagnostic.install
        end
        
        default_run
      end
      
      def run_daemonized
        # trap and ignore SIGHUP
        Signal.trap('HUP') {}
        
        pid = fork do
          begin
            require 'monitr'
            
            # set pid if requested
            if @options[:pid] # and as deamon
              Monitr.pid = @options[:pid] 
            end
            
            unless @options[:syslog]
              Logger.syslog = false
            end
            
            default_run
            
            unless Monitr::EventHandler.loaded?
              puts
              puts "***********************************************************************"
              puts "*"
              puts "* Event conditions are not available for your installation of monitr."
              puts "* You may still use and write custom conditions using the poll system"
              puts "*"
              puts "***********************************************************************"
              puts
            end
            
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
            abort "There was a fatal system error while starting monitr (see above)"
          end
        end
        
        if @options[:pid]
          File.open(@options[:pid], 'w') { |f| f.write pid }
        end
        
        ::Process.detach pid
        
        exit
      end
      
      def setup_logging
        log_file = Monitr.log_file
        log_file = File.expand_path(@options[:log]) if @options[:log]
        log_file = "/dev/null" if !log_file && @options[:daemonize]
        if log_file
          puts "Sending output to log file: #{log_file}" unless @options[:daemonize]
          
          # reset file descriptors
          STDIN.reopen "/dev/null"
          STDOUT.reopen(log_file, "a")
          STDERR.reopen STDOUT
          STDOUT.sync = true
        end
      end
      
      def load_config(config)
        if File.directory? config
          files_loaded = false
          Dir[File.expand_path('**/*.monitr', config)].each do |monitr_file|
            files_loaded ||= load_monitr_file(File.expand_path(monitr_file))
          end
          unless files_loaded
            abort "No files could be loaded"
          end
        else
          unless load_monitr_file(File.expand_path(config))
            abort "File could not be loaded"
          end
        end
      end
      
      def load_monitr_file(monitr_file)
        load File.expand_path(monitr_file)
      rescue Exception => e
        if e.instance_of?(SystemExit)
          raise
        else
          puts "There was an error in #{monitr_file}"
          puts "\t" + e.message
          puts "\t" + e.backtrace.join("\n\t")
          return false
        end
      end
      
    end # Run
    
  end
end