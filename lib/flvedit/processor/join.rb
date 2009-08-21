module FLV
  module Edit  
    module Processor

      # Join is a Processor class (see Base and desc)
      class Join < Base
        desc "Joins all the inputs together."

        include Dispatcher
    
        def each_source_with_join
          return to_enum(:each_source) unless block_given?
          yield
        end
        alias_method_chain :each_source, :join

        def each(&block)
          return to_enum unless block_given?
          each_source_without_join { super }
        end

        def on_tag(tag)
          if @wait_for_keyframe
            absorb
          else
            @last_timestamp = tag.timestamp
            tag.timestamp += @delta
          end
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
              @delta += @last_timestamp
            end
            dispatch_instead(Tag.new(@delta, evt = Event.new(:onNextSegment, :file => ::File.basename(h.path))))
          end
        end
      end

    end
  end
end