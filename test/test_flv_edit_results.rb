require File.dirname(__FILE__) + '/test_helper'

class TestFlvEdit < Test::Unit::TestCase
  context "Command line results" do
    Dir.glob(File.dirname(__FILE__)+"/text_flv_edit_results/*.txt").each do |fn|
      sep, args, sep, *expect = File.readlines(fn).map!(&:chomp)
      args = args.split(' ')
      args.unshift SHORT_FLV unless args.first.start_with?(".")
      
      context "for 'flvedit #{args.join(' ')}'" do
        setup do
          Time.stubs(:now).returns(Time.utc(2008,"dec",20))
          @result = ""
          runner = FLV::Edit::Runner.new(args)
          runner.options[:dont_catch_errors] = true
          runner.options[:out] = StringIO.new(@result)
          runner.run
        end
        should "match #{fn}" do
          @result = @result.split("\n")
          same = @result & expect
          assert_equal expect-same, @result-same
        end
      end
    end
  end
end