module FLV
  module Edit  
    module Processor

      class Join < Base
        desc "Join the FLV files"
    
        def process_next_file
          dispatch_chunks(@source) while @source.has_next_file?
        end

        def on_tag(tag)
          if @wait_for_keyframe
            absorb
          else
            tag.timestamp += @delta
          end
          @last_timestamp = tag.timestamp
        end
        
        def on_video(tag)
          @next_to_last_video_timestamp, @last_video_timestamp = @last_video_timestamp, tag.timestamp
        end
        
        def on_keyframe(tag)
          if @wait_for_keyframe
            @wait_for_keyframe = false
            @delta -= tag.timestamp
          end
        end

        def on_header(h)
          if is_first_header = !@delta
            @delta = 0
            @wait_for_keyframe = false
            @last_video_timestamp = 0
          else
            if @last_video_timestamp
              last_interval = @last_video_timestamp - @next_to_last_video_timestamp
              @delta += [@last_video_timestamp + last_interval, @last_timestamp].max
              @wait_for_keyframe = true
            else
              @delta = @last_timestamp
            end
            dispatch_instead(Tag.new(@last_timestamp, evt = Event.new(:onNextSegment, :file => ::File.basename(h.path))))
          end
        end
      end

    end
  end
end