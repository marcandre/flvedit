require_relative 'options'
require_relative 'processor'

module FLV
  module Edit
    class Runner
      attr_reader :options, :commands
      
      def initialize(*arg)
        @commands, @options = (arg.length == 1 ? Options.new(arg.first).to_a : arg)
      end
      
      def run
        commands = [*@commands].map{|c| c.is_a?(Class) ? c : Processor.const_get(c.to_s.camelize)}
        commands.unshift Processor::Reader
        commands << Processor::CommandLine unless options[:dont_catch_errors]
        Processor.chain(commands, @options).process_all
      end
      
      alias_method :run!,  :run
    end
  end
end