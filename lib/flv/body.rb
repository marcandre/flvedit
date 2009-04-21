module FLV
  
  # Common fonctionality to all types of Bodies (FLV::Audio, FLV::Video & FLV::Event)
  module Body
    def self.included(base)
      # Caution: order is important; InstanceMethods::is? relies on Base::is?
      base.class_eval do
        include Base
        include InstanceMethods
        include InstanceMethodsWhenString
      end
    end
    
    module InstanceMethods # :nodoc:
      def debug(format, *) #:nodoc
        format.values(to_h)
      end

      def is?(what)
        case what
          when String, Symbol
            super(what.to_s.downcase.gsub!(/_tag$/, "") || :never_match_on_class_name_unless_string_ends_with_tag)
          else
            super
        end
      end

      def similar_to?(other_body)
        getters.each{|getter| return false unless send(getter) == other_body.send(getter)}
        true
      end
    
      def title
        self.class.name + " tag"
      end
    end 
    
    module InstanceMethodsWhenString # :nodoc:
      # Returns an +Integer+ computed from bits specified by +which+.
      # The 0th bit is the most significant bit of the first character.
      # +which+ can designate a range of bits or a single bit
      def read_bits(which)
        which = which..which if which.is_a? Integer
        first_byte, last_byte = which.first >> 3, which.max >> 3
        return (getbyte(first_byte) >> (7 & ~which.max)) & ~(~1 << which.max-which.first) if(first_byte == last_byte)
        mid = last_byte << 3
        read_bits(which.first...mid) << (which.max - mid + 1)  |  read_bits(mid..which.max)
      end

      # We need to redefine this, since we want to end up with a Body, not a String
      def read_packed(io, options) #:nodoc:
        replace(io.read(String, options))
      end
    end  
  end
  
end