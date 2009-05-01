module FLV
  module Edit  
    module Processor

      # Dispatcher can be included in a processor and will makeit easy to 
      # process the chunks according to their type.
      #
      # Chunks can be Header or Tags.
      # The latter have different types of bodies: Audio, Video or Event.
      # Events store all meta data related information: onMetaData, onCuePoint, ...
      #
      # To tap into the flow of chunks, a processor can define any of the following methods:
      #   on_chunk
      #     on_header
      #     on_tag
      #       on_audio
      #       on_video
      #         on_keyframe
      #         on_interframe
      #         on_disposable_interframe
      #       on_event
      #         on_meta_data
      #         on_cue_point
      #         on_other_event
      #
      # All of these methods will have one argument: the current chunk being processed.
      # For example, if the current chunk is an 'onMetaData' event, then
      # the following will be called (from the most specialized to the least).
      #   on_meta_data(chunk)
      #   on_event(chunk)
      #   on_chunk(chunk)
      #
      # The methods need not return anything. It is assumed that the chunk should be output.
      # If that's not the case, call +#absorb+.
      # To output other tags instead, call +#dispatch_instead+.
      #
      # Note that both #absorb and #dispatch_instead stop the processing for the current chunk,
      # so if #on_video calls #absorb, for example, then there won't be a call to #on_tag or #on_chunk.
      #
      # Finally, it's possible to +#stop+ the processing of the current source completely.
      #
      module Dispatcher
        def initialize(*)
          super
          on_calls = self.class.instance_methods(false).select{|m| m.to_s.start_with?("on_")}.map(&:to_sym) #Note: to_s needed for ruby 1.9, to_sym for ruby 1.8
          unless (potential_errors = on_calls - ALL_EVENTS).empty?
            warn "The following are not events: #{potential_errors.join(',')} (class #{self.class})"
          end
        end

        # Stops the processing for the current chunk
        def absorb(*) # Note: the (*) is so that we can alias events like on_meta_data
          throw :absorb
        end
      
        # Stops the processing of the current source completely.
        def stop
          throw :stop
        end

        def each(&block)
          return to_enum unless block_given?
          @block = block
          catch :stop do
            super{|chunk| dispatch_chunk(chunk)}
          end
        end
        
        # Call #dispatch_instead with a list of chunks.
        # These chunks will not be processed by the current processor
        # but will be output directly. This stops the processing for
        # the current chunk.
        def dispatch_instead(*chunks)
          chunks.each do |chunk|
            @block.call chunk
          end
          absorb
        end      

        EVENT_TRIGGER = {
          :on_header      => :on_chunk,
          :on_tag         => :on_chunk,
          :on_audio       => :on_tag,
          :on_video       => :on_tag,
          :on_event       => :on_tag,
          :on_meta_data   => :on_event,
          :on_cue_point   => :on_event,
          :on_last_second => :on_event,
          :on_other_event => :on_event,
          :on_keyframe    => :on_video,
          :on_interframe  => :on_video,
          :on_disposable_interframe => :on_video
        }.freeze
      
        ALL_EVENTS = (EVENT_TRIGGER.keys | EVENT_TRIGGER.values).freeze
      
        MAIN_EVENTS = ALL_EVENTS.reject{ |k| EVENT_TRIGGER.has_value?(k)}.freeze
      
        EVENT_TRIGGER_LIST = Hash.new{|h, k| h[k] = [k] + h[EVENT_TRIGGER[k]]}.tap{|h| h[nil] = []; h.values_at(*MAIN_EVENTS)}.freeze
      
        module ClassMethods
          # Call give a list of events of #absorb to always absorb chunks of these types.
          def absorb(*events)
            events.each{|evt| alias_method evt, :absorb}
          end
        end
        
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end
      private
        def dispatch_chunk(chunk) # :nodoc:
          evt = chunk.main_event
          catch :absorb do
            EVENT_TRIGGER_LIST[evt].each do |event|
              send(event, chunk) if respond_to?(event)
            end
            @block.call chunk
          end
        end
      end #class Base


      # We supplement the basic FLV classes with a #main_event method
      # which returns the most specialize event for that chunk.
      module MainEvent # :nodoc:
        module Header
          def main_event
            :on_header
          end
        end

        module Video
          MAPPING = {
            :keyframe => :on_keyframe,
            :interframe => :on_interframe,
            :disposable_interframe => :on_disposable_interframe
          }.freeze

          def main_event
            MAPPING[frame_type]
          end
        end

        module Audio
          def main_event
            :on_audio
          end
        end

        module Event
          MAPPING = Hash.new(:on_other_event).merge!(
            :onMetaData => :on_meta_data,
            :onCuePoint => :on_cue_point,
            :onLastSecond => :on_last_second
          ).freeze
          def main_event
            MAPPING[event]
          end
        end
        
        module Tag
          def main_event
            body.main_event
          end
        end
      end #module MainEvent
    end #module Processor
  end #module Edit
  
  [Header, Tag, Audio, Video, Event].each do |klass|
    klass.class_eval{ include Edit::Processor::MainEvent.const_get(klass.to_s.sub('FLV::', '')) }
  end
  
end #module FLV