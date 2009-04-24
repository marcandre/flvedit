module FLV
  module Edit  
    module Processor

      # Cut is a Processor class (see Base and desc)
      class Cut < Base
        desc ["Cuts selects the tags within RANGE.",
              "The timestamps are offset so that the first tag has timestamp 0"],
              :param => {:class => TimestampRange, :name => "RANGE"}, :shortcut => "x"

        include Filter

        def before_filter
          @from, @to = options[:cut].begin, options[:cut].end
          @wait_for_keyframe = options[:keyframe_mode]
          @first_timestamp = nil
        end

        def filter(tag)
          return if tag.is_a? Header
          if tag.timestamp > @to
            stop
          elsif (tag.timestamp < @from) || (@wait_for_keyframe &&= !tag.body.is?(:keyframe))
            :skip
          else
            @first_timestamp ||= tag.timestamp
            tag.timestamp -= @first_timestamp
          end
        end
      end
    end
  end
end