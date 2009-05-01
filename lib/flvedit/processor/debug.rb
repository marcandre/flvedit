require_relative "printer"

module FLV
  module Edit  
    module Processor

      # Debug is a Processor class (see Base and desc)
      class Debug < Base
        include Filter
        desc ["Prints out the details of all tags. Information that stays the same",
              "from one tag type to the next will not be repeated.",
              "A RANGE argument will limit the output to tags within that range;",
              "similarily, a given TIMESTAMP will limit the output to tags",
              "within 0.1s of this timestamp."],
            :param => {:class => TimestampOrTimestampRange, :name => "[RANGE/TS]"}

        def before_filter
          @range = self.options[:debug] || TimestampRange.new(0, INFINITY)
          @range = @range.widen(0.1) unless @range.is_a? Range
          @last = {}
          @printer = Printer.new(options[:out])
        end
        
        def filter(tag)
          return unless @range.include? tag.timestamp
          tag.debug(@printer, @last[tag.body.class])
          @last[tag.body.class] = tag
        end
      end
    end
  end
end