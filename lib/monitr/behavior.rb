module Monitr
  
  class Behavior
    include Configurable
    
    attr_accessor :watch
    
    # Generate a Behavior of the given kind. The proper class is found by camel casing the
    # kind (which is given as an underscored symbol).
    #   +kind+ is the underscored symbol representing the class (e.g. foo_bar for Monitr::Behaviors::FooBar)
    def self.generate(kind, watch)
      sym = kind.to_s.capitalize.gsub(/_(.)/){$1.upcase}.intern
      b = Monitr::Behaviors.const_get(sym).new
      b.watch = watch
      b
    rescue NameError
      raise NoSuchBehaviorError.new("No Behavior found with the class name Monitr::Behaviors::#{sym}")
    end
    
    def valid?
      true
    end
        
    #######
    
    def before_start
    end
    
    def after_start
    end
    
    def before_restart
    end
    
    def after_restart
    end
    
    def before_stop
    end
    
    def after_stop
    end
    
    # Construct the friendly name of this Behavior, looks like:
    #
    # Behavior FooBar on Watch 'baz'
    def friendly_name
      "Behavior " + super + " on Watch '#{self.watch.name}'"
    end
  end
  
end