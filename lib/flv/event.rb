module FLV
  # The body of a tag containing meta data, cue points or last second information
  # These behave like a Hash. The keys should be symbols
  # while the values can be about any type, including arrays and hashes.
  class Event < Hash
    include Packable
    include Body
    TYPICAL_EVENTS = [:onMetaData, :onCuePoint, :onCaption, :onCaptionInfo, :onLastSecond, :onEvent]
    attr_accessor :event

    def initialize(event = :onMetaData, h = {})
      self.replace h
      self.event = event.to_sym
    end

    def read_packed(io,options) #:nodoc:
      len = io.pos_change do
        evt, h = io >>:flv_value >>:flv_value
        self.event = evt.to_sym
        replace h
      end
      FLV::Util.double_check :size, options[:bytes], len
    end
    
    def write_packed(io,*) #:nodoc:
      io << [event.to_s, :flv_value] << [self, :flv_value]
    end

    def debug(format, *)
      format.values(:event => event)
      format.values(self)
    end
    
    def is?(what)
      event.to_s == what.to_s || super
    end
    
    alias_method :similar_to?, :==
  end
end