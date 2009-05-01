module FLV
  # The body of an audio tag.
  # The data is quite complex stuff. We make no attempt to understand it all
  # or to be able to modify any of it. We simply consider it a complex string
  # and read the interesting bits to give more info.
  class Audio < String
    include Body

    FORMATS = Hash.new{|h, key| "Unknown audio format: #{key}"}.merge!(
      0  => :"Linear PCM, platform endian"  ,
      1  => :ADPCM                          ,
      2  => :MP3                            ,
      3  => :"Linear PCM, little endian"    ,
      4  => :"Nellymoser 16-kHz mono"       ,
      5  => :"Nellymoser 8-kHz mono"        ,
      6  => :Nellymoser                     ,
      7  => :"G.711 A-law logarithmic PCM"  ,
      8  => :"G.711 mu-law logarithmic PCM" ,
      10 => :AAC                            ,
      11 => :Speex                          ,
      14 => :"MP3 8-kHz"                    ,
      15 => :"Device-specific sound"
    ).freeze
    
    EXCEPTIONS = Hash.new({}).merge(
      :"Nellymoser 8-kHz mono"  => {:channel => :mono,  :rate => 8000},
      :"Nellymoser 16-kHz mono" => {:channel => :mono,  :rate => 16000},
      :AAC                      => {:channel => :stereo,:rate => 44000},
      :"MP3 8-kHz"              => {:rate => 8000}
    ).freeze
    
    CHANNELS = {
      0 => :mono,
      1 => :stereo
    }.freeze

    def codec_id
      read_bits(0..3)
    end
    
    # Returns the format (see Audio::FORMATS for list)
    def format
      FORMATS[codec_id]
    end
    
    # returns :mono or :stereo
    def channel
      EXCEPTIONS[format][:channel] ||
        CHANNELS[read_bits(7)]
    end

    # Returns the sampling rate (in Hz)
    def rate
      EXCEPTIONS[format][:rate] ||
        5500 << read_bits(4..5)
    end
    
    # Returns the sample size (in bits)
    def sample_size
      EXCEPTIONS[format][:sample_size] ||
        8 << read_bits(6)
    end
    
    def is?(what)
      format.to_s.downcase == what.to_s.downcase || super
    end
    
  end
end