module Monitr
  module CLI
    
    class Version
      def self.version
        require 'monitr'
    
        # print version
        puts "Version #{Monitr::VERSION}"
        exit
      end
      
      def self.version_extended
        puts "Version: #{Monitr::VERSION}"
        puts "Polls: enabled"
        puts "Events: " + Monitr::EventHandler.event_system
    
        exit
      end
    end
    
  end
end