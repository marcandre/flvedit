require 'delegate'
require 'optparse'

module FLV
  class Timestamp < DelegateClass(Float)
    def initialize(ms=0)
      raise ArgumentError unless ms.is_a? Numeric
      super
    end
    
    # Returns [hours, minutes, seconds, milliseconds]
    def to_a
      n = in_milliseconds
      [1000,60,60].map do |div|
        val = n % div
        n /= div
        val
      end.reverse.unshift(n)
    end
    
    # Returns "HH:MM:SS.MMMM" like "1:23:45.678" or "1:00.000" for 1 minute.
    def to_s
      return "" if self == INFINITY
      nbs = to_a.drop_while(&:zero?)
      ms = nbs.pop || 0
      first = nbs.shift || 0
      sprintf("%d%s.%03d", first, nbs.map{|n| sprintf(":%02d",n)}.join, ms)
    end

    def in_seconds
      to_f
    end
    
    def in_milliseconds
      (self * 1000).round
    end
    
    def widen(amount)
      TimestampRange.new(self,self).widen(amount)
    end
    
    def self.in_milliseconds(ms)
      Timestamp.new(ms/1000.0)
    end
    
    def self.in_seconds(s)
      new s
    end

    def self.try_convert(s, if_empty_string = 0)
      case s
      when Timestamp
        s
      when Numeric
        new s
      when ""
        new if_empty_string
      when REGEXP
        h, m, s, ms = Regexp.last_match.captures
        ms &&= ms.ljust(3,'0')[0,3] # e.g. 1.23 => 1.230
        h, m = m, h if h and h.end_with?(":") and m.nil?
        h, m, s, ms = [h, m, s, ms].map{|n| (n || 0).to_i}
        in_seconds ((h*60+m)*60+s)+ms/1000.0
      end
    end
    
    REGEXP = /^(\d*[h:])?(\d*[m:])?(\d*)\.?(\d*)$/.freeze
  end # Timestamp
  
  INFINITY = 1/0.0
  class TimestampRange < Range
    core = Timestamp::REGEXP.source.gsub(/[\$\^\(\)]/,"")
    REGEXP = Regexp.new("^(#{core})-(#{core})$").freeze
    
    def to_s
      "#{self.begin}-#{self.end}"
    end
    
    def initialize(from, to, exclusive=false)
      super(Timestamp.try_convert(from), Timestamp.try_convert(to, INFINITY), exclusive)
    end
    
    def in_seconds
      Range.new(self.begin.in_seconds, self.end.in_seconds, self.exclude_end?)      
    end

    def in_milliseconds
      Range.new(self.begin.in_milliseconds, self.end.in_milliseconds, self.exclude_end?)
    end
    
    def self.try_convert(s)
      case s
      when Range
        new s.begin, s.end
      when TimestampRange
        s
      when REGEXP
        new *Regexp.last_match.captures
      else
        p "Can't convert #{s}"
      end
    end
    
    def widen(amount)
      TimestampRange.new [self.begin - amount, 0].max, self.end + amount, self.exclude_end?
    end
  end # TimestampRange
  OptionParser.accept(TimestampRange, TimestampRange::REGEXP) {|str,from,to| TimestampRange.try_convert(str)}
  
  
  class TimestampOrTimestampRange  # :nodoc:
    core = Timestamp::REGEXP.source.gsub(/[\$\^\(\)]/,"")
    REGEXP = Regexp.new("^(#{core})-(#{core})|(#{core})$").freeze
  end # TimestampOrTimestampRange
  OptionParser.accept(TimestampOrTimestampRange, TimestampOrTimestampRange::REGEXP) do |str,from, to, from_to|
    (from_to ? Timestamp : TimestampRange).try_convert(str)
  end
end

class Range # :nodoc:
  def ==(r) # Override built-in == because of bug in Ruby 1.8 & 1.9, see http://redmine.ruby-lang.org/issues/show/1165
    self.begin == r.begin && self.end == r.end && self.exclude_end? == r.exclude_end?
  end
end