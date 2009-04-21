module FLV
  module Edit  
    module Processor
      class Cut < Base
        desc ["Cuts file using the given RANGE"],
              :param => {:class => TimestampRange, :name => "RANGE"}, :shortcut => "x"

        def on_header(*)
          @from, @to = options[:cut].begin, options[:cut].end
          @wait_for_keyframe = options[:keyframe_mode]
          @first_timestamp = nil
        end

        def on_tag(tag)
          if tag.timestamp > @to
            stop
          elsif (tag.timestamp < @from) || (@wait_for_keyframe &&= !tag.body.is?(:keyframe))
            absorb
          else
            @first_timestamp ||= tag.timestamp
            tag.timestamp -= @first_timestamp
          end
        end
      end
    end
  end
end