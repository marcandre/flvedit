module FLV
  module Edit
    module Processor
      class MetaDataMaker < Base        
        CHUNK_LENGTH_SIZE = 4 # todo: calc instead?
        TAG_HEADER_SIZE = 11 # todo: calc instead?
        TOTAL_EXTRA_SIZE_PER_TAG = CHUNK_LENGTH_SIZE + TAG_HEADER_SIZE
        Info = Struct.new(:bytes, :tag_count, :first, :last)
      
        def total_size
          @info.values.sum{|h| h.bytes + h.tag_count * TOTAL_EXTRA_SIZE_PER_TAG}
        end
      
        def on_header(header)
          @cue_points = []
          @key_frames = []
          @video_interval_stats = Hash.new(0)
          @info = Hash.new{|h, key| h[key] = Info.new(0,0,nil,nil)}
          @info[Header].bytes = header.size
          # Header is not a tag, so leave tag_count at 0
        end
  
        def on_tag(tag)
          h = @info[tag.body.class]
          h.first ||= tag
          h.last = tag
          h.bytes += tag.body.size
          h.tag_count += 1
        end
      
        def on_meta_data(t)
          @previous_meta = t
          absorb
        end
      
        def on_video(t)
          @video_interval_stats[t.timestamp.in_milliseconds - @info[Video].last.timestamp.in_milliseconds] += 1   if @info[Video].last
        end
        
        def on_keyframe(t)
          @key_frames << [t.timestamp.in_seconds, self.total_size]
        end

        def on_cue_point(t)
          @cue_points << t
        end

        def time_positions_to_hash(time_position_pairs)
          times, filepositions = time_position_pairs.transpose
          {:times => times || [], :filepositions => filepositions || []}
        end
      
        def meta_data
          frame_sequence_in_ms = @video_interval_stats.index(@video_interval_stats.values.max)
          last_ts = @info.values.map{|h| h.last}.compact.map(&:timestamp).map(&:in_seconds).max
          duration = last_ts + frame_sequence_in_ms/1000.0

          meta = @info[Video].last.body.dimensions if @info[Video].last
          meta ||= {:width => @previous_meta[:width], :height => @previous_meta[:height]} if @previous_meta
          meta ||= {}
          [Video, Audio].each do |k|
            h = @info[k]
            type = k.name.gsub!("FLV::","").downcase

            meta[:"#{type}size"] = h.bytes + h.tag_count * TAG_HEADER_SIZE
            meta[:"#{type}datarate"] = h.bytes / duration * 8 / 1000 #kbits/s
            if meta[:"has#{type.capitalize}"] = h.first != nil
              meta[:"#{type}codecid"] = h.first.codec_id
            end
          end
                
          meta.merge!(
            :filesize               => total_size,
            :datasize               => total_size - @info[Header].bytes - CHUNK_LENGTH_SIZE*(1 + @info.values.sum(&:tag_count)),
            :lasttimestamp          => last_ts,
            :framerate              => frame_sequence_in_ms ? 1000.0/frame_sequence_in_ms : 0,
            :duration               => duration,

            :hasCuePoints           => !@cue_points.empty?,
            :cuePoints              => @cue_points.map(&:body),
            :hasKeyframes           => !@key_frames.empty?,
            :keyframes              => time_positions_to_hash(@key_frames),

            :hasMetadata            => true, #duh! Left for compatibility with FLVTool2, but I can't believe anyone would actually check on this...
            :metadatadate           => Time.now,
            :metadatacreator        => 'flvedit........................................................'
          )

          meta.merge!(
            :audiodelay             => @info[Video].first.timestamp.in_seconds,
            :canSeekToEnd           => @info[Video].last.frame_type == :keyframe,
            :lastkeyframetimestamp  => @key_frames.last.first || 0
          ) if meta[:hasVideo]
        
          meta.merge!(
            :stereo                 => @info[Audio].first.channel == :stereo,
            :audiosamplerate        => @info[Audio].first.rate,
            :audiosamplesize        => @info[Audio].first.sample_size
          ) if meta[:hasAudio]
        
          # Adjust all sizes for this new meta tag
          meta_size = Tag.new(0, meta).size
          # p "Size of meta: #{meta_size}"
          # p "Info: #{@info.values.map(&:bytes).inspect} #{@info.values.map(&:tag_count).inspect}"
          meta[:filesize] += meta_size
          meta[:datasize] += meta_size
          meta[:keyframes][:filepositions].map! {|ts| ts + meta_size} if meta[:hasKeyframes]
          meta[:cuePoints][:filepositions].map! {|ts| ts + meta_size} if meta[:hasCuePoints]
        
          meta
        end
    
          # def add_meta_data_tag(stream, options)
          #   # add onLastSecond tag
          #   onlastsecond = FLV::FLVMetaTag.new
          #   onlastsecond.timestamp = ((stream.duration - 1) * 1000).to_int
          #   stream.add_tags(onlastsecond, false) if onlastsecond.timestamp >= 0
          # 
          #   stream.add_meta_tag({ 'metadatacreator' => options[:metadatacreator], 'metadatadate' => Time.now }.merge(options[:metadata]))
          #   unless options[:compatibility_mode]
          #     stream.on_meta_data_tag.meta_data['duration'] += (stream.frame_sequence_in_ms || 0) / 1000.0
          #   end
          # end
      end
    end
  end
end