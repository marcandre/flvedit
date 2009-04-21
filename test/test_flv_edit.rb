require File.dirname(__FILE__) + '/test_helper'

class TestFlvEdit < Test::Unit::TestCase
  context "Options parsing" do
    setup do
      @options = FLV::Edit::Options.new([SHORT_FLV, "--Debug"])
    end
    
    should "detect files" do
      assert_equal [SHORT_FLV], @options.options[:files]
    end
    
  end
  
  context "Command line tool" do
    setup do
      File.delete(TEMP_FLV) if File.exist?(TEMP_FLV)
    end
    
    should "save" do
      assert !File.exist?(TEMP_FLV)
      runner = FLV::Edit::Runner.new([SHORT_FLV, "--Update", "--Save", TEMP_FLV])
      runner.options[:dont_catch_errors] = true
      runner.run
      assert File.exist?(TEMP_FLV)
    end
    
    teardown do
      File.delete(TEMP_FLV) if File.exist?(TEMP_FLV)
    end
  end
end