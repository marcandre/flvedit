module FLV
  # The body of a video tag.
  # The data is quite complex stuff. We make no attempt to understand it all
  # or to be able to modify any of it. We simply consider it a complex string
  # and read the interesting bits to give more info.
  class Video < String
    include Body
    CODECS = Hash.new(:unknown).merge!(
      1 => :JPEG,
      2 => :h263,
      3 => :screen,
      4 => :on2_vp6,
      5 => :on2_vp6_alpha,
      6 => :screen_v2,
      7 => :AVC
    ).freeze
    
    FRAMES = Hash.new(:unknown).merge!(
      1 => :keyframe  ,
      2 => :interframe,
      3 => :disposable_interframe
    ).freeze
    
    def frame_type
      FRAMES[read_bits(0...4)]
    end

    def codec_id
      read_bits(4...8)
    end
    
    def codec
      CODECS[codec_id]
    end

    # Dimensions for h263 encoding; either as a bit range or the final value
    H263_DIMENSIONS = {
      0 => [41...49, 49...57],
      1 => [41...57, 57...73],
      2 => [352, 288],
      3 => [176, 144],
      4 => [128, 96] ,
      5 => [320, 240],
      6 => [160, 120]
    }.freeze

    # Returns dimensions as {:width => w, :height => h}, for Sorensen H.263 and screen video codecs only (otherwise returns nil)
    def dimensions
      w, h = case codec
        when :h263
          H263_DIMENSIONS[read_bits(38...41)]
        when :screen
          [12...24, 24...32]
      end
      return nil unless w
      w, h = [w, h].map{ |r| read_bits(r) } if w.is_a?(Range)
      {:width => w, :height => h}
    end
    
    def is?(what)
      frame_type.to_s.downcase == what.to_s.downcase || super
    end
    
    def getters
      super - [:frame_type, :frame_type.to_s]  # Let's exclude the frame_type from the normal attributes... (string vs symbol: ruby 1.8 vs 1.9)
    end
    
    def title
      super + " (#{frame_type})"  # ...and include it in the title instead.
    end
    
  end
end
