module FLV  
  # FLV files consists of a single header and a collection of Tags.
  # Tags all have a timestamp and a body; this body can be Audio, Video, or Event.
  class Tag
    include Base
    attr_accessor :body, :timestamp

    def timestamp=(t)
      @timestamp = Timestamp.try_convert(t)
    end
    
    def initialize(timestamp = 0, body = nil)
      self.body = body.instance_of?(Hash) ? Event.new(:onMetaData, body) : body
      self.timestamp = timestamp
    end
    
    CLASS_CODE = {
      8 => Audio,
      9 => Video,
      18 => Event
    }.freeze

    def write_packed(io, *) #:nodoc
      packed_body = @body.pack
      len = io.pos_change do
        io  << [CLASS_CODE.key(self.body.class), :char] \
            << [packed_body.length, :unsigned_24bits]     \
            << [@timestamp.in_milliseconds, :unsigned_24bits]       \
            << [@timestamp.in_milliseconds >>24, :char]              \
            << [streamid=0, :unsigned_24bits]             \
            << packed_body
      end
      io << [len, :unsigned_long]
    end
    
    def read_packed(io, options) #:nodoc
      len = io.pos_change do 
           code,    body_len,           timestamp_in_ms,   timestamp_in_ms_ext,  streamid =
        io >>:char  >>:unsigned_24bits  >>:unsigned_24bits  >>:char               >>:unsigned_24bits
        @timestamp = Timestamp.in_milliseconds(timestamp_in_ms + (timestamp_in_ms_ext << 24))
        @body = io.read CLASS_CODE[code] || Body, :bytes => body_len
      end
      FLV::Util.double_check :size, len, io.read(:unsigned_long) #todo
    end

    def debug(format, compared_with = nil) #:nodoc
      format.header("#{timestamp} ", @body.title)
      @body.debug(format) unless compared_with && @body.similar_to?(compared_with.body)
    end

    def is?(what) #:nodoc
      super || body.is?(what)
    end
    
    def method_missing(*arg, &block)
      super
    rescue NoMethodError
      body.send(*arg, &block)
    end
    
  end
end
