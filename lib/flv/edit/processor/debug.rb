require_relative "printer"

module FLV
  module Edit  
    module Processor
      class Debug < Base
        desc ["Prints out the details of all tags. Information that stays the same",
              "from one tag type to the next will not be repeated.",
              "A RANGE argument will limit the output to tags within that range;",
              "similarily, a given TIMESTAMP will limit the output to tags",
              "within 0.1s of this timestamp."],
            :param => {:class => TimestampOrTimestampRange, :name => "[RANGE/TS]"}
        def on_header(tag)
          @range = self.options[:debug] || TimestampRange.new(0, INFINITY)
          @range = @range.widen(0.1) unless @range.is_a? Range
          @last = {}
          @printer = Printer.new(stdout)
          tag.debug(@printer) if @range.include? 0
        end

        def on_tag(tag)
          return unless @range.include? tag.timestamp
          tag.debug(@printer, @last[tag.body.class])
          @last[tag.body.class] = tag
        end

      end
    end
  end
end