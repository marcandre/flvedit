require 'singleton'

module FLV
  # FLV files can contain structured data. This modules makes it easy to (un)pack that data.
  # The packing option +flv_value+ can (un)pack any kind of variable.
  # It corresponds to +SCRIPTDATAVALUE+ in the official FLV file format spec.
  # Implementation Note:
  # +flv_value+ is actually simply a wrapper that will (un)pack the type of variable;
  # the actual data is (un)packed with the format +flv+, which is independently defined for each type
  module Packing
    
    # A special kind of value used to signify the end of a list (implemented at the end)
    class EndOfList  # :nodoc:
    end

  #=== Top-level :flv_value filter:
  
    TYPE_TO_CLASS = Hash.new do |h, type|
      #EndOfList
      raise IOError, "Invalid type for a flash variable. #{type.inspect} is not in #{h.keys}" #todo: handle error for corrupted da
    end.merge!(
       0 => Numeric   ,
       1 => TrueClass , # There really should be a Boolean class!
       2 => String    ,
       3 => Hash      ,
       8 => [Hash, :flv_with_size],
       9 => EndOfList ,
      10 => Array     ,
      11 => Time      ,
      nil => NilClass
    ).freeze
    
    CLASS_TO_TYPE = Hash.new do |h, klass|
      # Makes it such that CLASS_TO_TYPE[Fixnum] = CLASS_TO_TYPE[Integer], etc.
      h[klass] = h[klass.superclass]
    end.merge!(TYPE_TO_CLASS.invert).merge!(
      Event => TYPE_TO_CLASS.key([Hash, :flv_with_size]), # Write Events as hashes with size
      FalseClass => TYPE_TO_CLASS.key(TrueClass)
    )

    # Read/write the type and (un)pack the actual data with :flv
    Object.packers.set(:flv_value) do |packer|
      packer.write do |io|
        type_nb = CLASS_TO_TYPE[self.class]
        raise "Trying to write #{self.inspect}" unless type_nb
        klass, format = TYPE_TO_CLASS[type_nb]
        io << [type_nb, :char] << [self, format || :flv]
      end
      packer.read  do |io|
        klass, format = TYPE_TO_CLASS[io.read(:char)]
        io.read([klass, format || :flv])
      end
    end

  #=== For each basic type, the :flv filter (un)packs the actual data:

    Numeric.packers.set(:flv) do |packer|
      # Both Integers and Floats are packed as doubles
      packer.write {|io| io << [to_f, :double] }
      packer.read  do |io|
        n = io.read(:double)
        n.to_i == n ? n.to_i : n
      end
    end

    [TrueClass, FalseClass].each do |klass|
      klass.packers.set(:flv) do |packer|
        packer.write {|io| io << [self ? 1 : 0, :char] }
        packer.read  {|io| io.read(:char) != 0 }
      end
    end

    String.packers.set(:flv) do |packer|
      packer.write {|io| io << [length, :unsigned_short] << self }
      packer.read  {|io| io.read(io.read(:unsigned_short)) }
    end
    
    Array.packers.set(:flv) do |packer|
      packer.write do |io|
        io << [length, :unsigned_long]
        each do |value|
          io << [value, :flv_value]
        end
      end
      packer.read do |io|
        nb = io.read(:unsigned_long)
        io.each(:flv_value).take(nb)
      end
    end

    # The default format for hashes has a useless hint for the size
    # This filter simply acts as a wrapper for the :flv_without_size filter
    Hash.packers.set(:flv_with_size) do |packer|
      packer.write do |io|
        io << [length, :unsigned_long] << [self, :flv]
      end
      packer.read  do |io|
        ignore_length_hint = io >> :unsigned_long
        io.read [Hash, :flv]
      end
    end

    Hash.packers.set(:flv) do |packer|
      packer.write do |io|
        each do |key, value|
          io << [key.to_s, :flv] << [value, :flv_value] rescue raise "Hash[#{key}] is set to #{value.inspect}"
        end
        io << ["", :flv] << [EndOfList.instance, :flv_value]
      end
      packer.read  do |io|
        Hash[
          io.each([String, :flv], :flv_value).
            # take_while {|str, val|  val != EndOfList.instance }.
            take_while do |str, val|  
              if str == "" && val != EndOfList.instance
                p "***Warning: read #{val.inspect} as end of list!?"
              end
              val != EndOfList.instance
              str != ""
            end.
            map{|k,v| [k.to_sym, v]}
        ]
      end
    end

    Time.packers.set(:flv) do |packer|
      packer.write {|io| io << [to_f * 1000, :double] << [Time.now.gmtoff / 60, :short] }
      packer.read do |io|
        seconds, zone = io >> :double >> :short
        Time.at((seconds / 1000).to_i) + (zone * 60) - Time.now.gmtoff
      end
    end
    
    class EndOfList # :nodoc:
      include Singleton, Packable
      packers.set(:flv) do |packer|
        packer.write { |dummy| } # no data to write
        packer.read {EndOfList.instance}
      end
    end
    
    Integer.packers.set :unsigned_24bits,  :bytes => 3, :signed => false, :endian => :big
  end #module Packing
end #module FLV