module FLV
  module Edit  
    module Processor
      # Processors are used to process FLV files. Processors form are chain and the data (header and tags) will 'flow'
      # through the chain in sequence. Each processor can inspect the data and change the flow,
      # either by modifying the data, inserting new data in the flow or stopping the propagation of data.
      #
      # A FLV file can be seen as a sequence of chunks, the first one being a Header and the following ones
      # a series of Tags with different types of bodies: Audio, Video or Event. Events store all meta data
      # related information: onMetaData, onCuePoint, ...
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
      #   processor.on_meta_data(chunk)
      #   processor.on_event(chunk)
      #   processor.on_chunk(chunk)
      #   # later on, the next processor will handle it:
      #   next_processor.on_meta_data(chunk)
      #   #...
      #
      # The methods need not return anything. It is assumed that the chunk will continue to flow through the
      # processing chain. When the chunk should not continue down the chain, call +absorb+.
      # To insert other tags in the flow, call +dispatch_instead+.
      # Finally, it's possible to +stop+ the processing of the file completely.
      #
      # It is possible to look back at already processed chunks (up to a certain limit) with +look_back+
      # or even in the future with +look_ahead+
      #
      module Dispatcher
        def initialize(*)
          super
          on_calls = self.class.instance_methods(false).select{|m| m.to_s.start_with?("on_")}.map(&:to_sym) #Note: to_s needed for ruby 1.9, to_sym for ruby 1.8
          unless (potential_errors = on_calls - ALL_EVENTS).empty?
            warn "The following are not events: #{potential_errors.join(',')} (class #{self.class})"
          end
        end

        def absorb(*) # Note: the (*) is so that we can alias events like on_meta_data
          throw :absorb
        end
      
        def stop
          throw :stop
        end

        def each(&block)
          return to_enum unless block_given?
          @block = block
          catch :stop do
            source.each{|chunk| dispatch_chunk(chunk)}
          end
        end
      
        def process_next_file
          dispatch_chunks(@source)
        end
        
        def dispatch_chunks(enum)
          enum.each do |chunk|
            dispatch_chunk(chunk)
          end
        end

        def dispatch_chunk(chunk)
          evt = chunk.main_event
          catch :absorb do
            EVENT_TRIGGER_LIST[evt].each do |event|
              send(event, chunk) if respond_to?(event)
            end
            @block.call chunk
          end
        end
      
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
          def absorb(*events)
            events.each{|evt| alias_method evt, :absorb}
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
      end #class Base


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