require File.dirname(__FILE__) + '/test_helper'

class TestFlv < Test::Unit::TestCase
  context "Timestamp" do
    context "conversion" do
      { 0 => "0.000"             ,
        1 => "0.001"             ,
        1000 => "1.000"          ,
        12_345 => "12.345"       ,
        61_000 => "1:01.000"     ,
        601_000 => "10:01.000"     ,
        3600_000 => "1:00:00.000"
      }.each do |n, s|
        should "convert between #{s} and #{n} ms" do
          assert_equal s, FLV::Timestamp.in_milliseconds(n).to_s
          assert_equal n, FLV::Timestamp.try_convert(s).in_milliseconds
        end
      end
  
      { "0" => 0 ,
        "1" => 1000,
        "1.0" => 1000,
        "1m" => 60_000,
        "1h" => 60 * 60_000,
        "1::" => 60 * 60_000,
        "1h23m45.6789" => 60 * 60_000 + 23*60_000 + 45678
      }.each do |s, n|
        should "convert #{s} to #{n} ms" do
          assert_equal n, FLV::Timestamp.try_convert(s).in_milliseconds
        end
      end
    end
  end
 
  context "TimestampRange" do
    context "conversion" do
      { "1:02-" => 62..(1/0.0),
        "-1.23" => 0..1.23,
        "12345-1:02:03.456" => 12345..3723.456,
        "2m.345-1h" => 120.345..3600
      }.each do |s, r|
        should "convert #{s} to #{r} ms" do
          assert_equal r, FLV::TimestampRange.try_convert(s).in_seconds
        end
      end
    end
  end
 

  BIT_TEST = "\x01\x02\xff"
  context "Bit reading from #{BIT_TEST.inspect}" do
    setup do
      @body = BIT_TEST.clone
      class <<@body
        include FLV::Body
      end
    end
    
    [ [0..0,  0],
      [0...7, 0],
      [0..7,  1],
      [6..7,  1],
      [7..7,  1],
      [14, 1],
      [3..9,  0b100],
      [3...15,0b1_0000_001],
      [3..15, 0b1_0000_0010],
      [3..16, 0b1_0000_0010_1]
    ].each do |bits, val|
      should "return #{val} for bits #{bits}" do
        assert_equal val, @body.read_bits(bits)
      end
    end
  end
    
  context "Packing" do
    context "a header" do
      setup do
        @header = FLV::Header.new
        @header.extra = "hello"
        @header.has_audio = true
      end
    
      should "work" do
        assert_equal "FLV\001\004\000\000\000\016hello\000\000\000\000",
                      @header.pack
      end
    end
    
    context "an audio tag" do
      setup do
        @tag = FLV::Tag.new(FLV::Timestamp.in_milliseconds(0x1234), FLV::Audio.new("bogus audio data!"))
      end
      
      should "work" do
        assert_equal "\b\000\000\021\000\x12\x34\000\000\000\000bogus audio data!\000\000\000\034",
                      @tag.pack
      end
    end
  end

  context "Unpacking" do
    setup do
      @io = StringIO.new("FLV\001\004\000\000\000\016hello\000\000\000\000!!")
      @header = @io.packed.read(FLV::Header)
    end
    
    should "read the header correctly" do
      assert_equal "hello", @header.extra
      assert_equal true,    @header.has_audio
      assert_equal false,   @header.has_video
    end
    
    should "read just what's required" do
      assert_equal "!!",    @io.read
    end
  end
  
  context "Packing + Unpacking" do
    should "return the same object" do
      obj = {
        :event => "onMetaData"                ,
        :audiocodecid => 2                    ,
        :audiodatarate => 15.7066666666667    ,
        :canSeekToEnd => false                ,
        :hasAudio => true                     ,
        :cuePoints => []                      ,
        :keyframes => {:filepositions=>[846, 1968], :times=>[0.0, 0.2]},
        :metadatadate => Time.gm(2000,"jan",1,20,15,1)
      }
      io = StringIO.new("").packed
      io.write(obj, :flv_value)
      p io.string
      io.rewind
      assert_equal(obj, io.read(:flv_value))
      assert io.eof?
    end
  end

  context "Typematch" do
    setup do
      @chunks = FLV::File.open(SHORT_FLV).each.first(4)
    end
    
    should "work" do
      assert_equal false, @chunks[2].is?(:audio)
    end
    
    {
      :header       => [true , false, false, false],
      :tag          => [false, true , true , true ],
      :audio        => [false, false, false, false],
      :audio_tag    => [false, false, true , false],
      :nellymoser   => [false, false, false, false],
      :mP3          => [false, false, true , false],
      :event_tag    => [false, true , false, false],
      :onMetaData   => [false, true , false, false],
      :onCuePoint   => [false, false, false, false],
    }.each do |check, answers|
      should "work for #{check}" do
        assert_equal answers, @chunks.map{|t| t.is?(check) }, check
      end
    end
  end
    
end