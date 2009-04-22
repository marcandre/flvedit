module FLV
  module Edit
    module Processor
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
          puts (["**** Processed with errors: ****"] + errors.map{|path, err| "#{path}: #{err}"}).join("\n") unless errors.empty?
        end
      end
    end
  end
end