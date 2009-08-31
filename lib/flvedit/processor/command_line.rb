module FLV
  module Edit
    module Processor

      # CommandLine is a Processor (see Base) added automatically as the last level
      # for all command line executions
      class CommandLine < Base
        include Dispatcher
        def on_header(h)
          @last = h.path
        end
      
        def each_source
          return to_enum(:each_source) unless block_given?
          ok, errors = [], []
          super do
            begin
              each{}
              ok << @last
            rescue Exception => e
              errors << [@last, e]
            end
          end
          puts (["Processed successfully:"] + ok).join("\n") unless ok.empty?
          puts "**** Processed with errors: ****" unless errors.empty?
          errors.map do |path, err|
            puts "#{path}: #{err}\n"+err.backtrace.join("\n")
          end
        end
      end
    end
  end
end