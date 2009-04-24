module FLV
  # Represents the header chunk present at the very beginning of any FLV file.
  class Header
    include Base
    attr_accessor :version, :has_audio, :has_video, :extra, :path

    FLV_SIGNATURE = [String, {:bytes => 3}].freeze
    SIGNATURE = 'FLV'
    MIN_OFFSET = 9
    FLAGS = { :has_video => 1, :has_audio => 4 }.freeze

    def read_packed(io, *) #:nodoc:
          signature,        self.version, type_flags, offset  = \
      io  >> FLV_SIGNATURE  >> :char      >> :char    >> :unsigned_long 

      raise RuntimeError.new("typeflags is #{signature}, #{version}, #{type_flags}, #{offset}") unless Fixnum === type_flags
      
      FLAGS.each {|flag,mask| send("#{flag}=", type_flags & mask > 0) }
      self.extra = io.read(offset - MIN_OFFSET)
      ignore_PreviousTagSize0 = io.read :unsigned_long
      self.path = io.try :path
      raise IOError("Wrong Signature (#{signature} instead of #{SIGNATURE})") unless SIGNATURE == signature
    end

    def write_packed(io, *) #:nodoc:
      self.extra ||= ""
      type_flags = FLAGS.sum{|flag, mask | send(flag) ? mask : 0}
      io << SIGNATURE << [self.version || 1, :char] << [type_flags, :char] <<
            [MIN_OFFSET + self.extra.length, :unsigned_long] << self.extra << [0, :unsigned_long]
    end
    
    def debug(format, *)
      format.header("Header", path)
      format.values(to_hash.tap{|h| [:path, :timestamp, :body].each{|key| h.delete(key)}})
    end
    
    def timestamp
      0
    end
    
    def body
      self
    end
  end
end
