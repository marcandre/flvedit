module FLV
  class IOError < ::IOError  # :nodoc:
  end
  
  module Util # :nodoc:
    def self.double_check(event, expected, actual)
      Checking.fail_check(event, expected, actual) unless [*expected].include? actual
    end
  
    class Checking # :nodoc:
      class << self
        attr_accessor :strict
        def fail_check(event, expected, actual)
          err = "Mismatch on #{event}: expected #{expected} vs #{actual}"
          raise IOError, err if strict
          #STDERR << "Caution: "+ err
        end
      end
    end
  
  end
end