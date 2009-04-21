module FLV
  module Edit
    module Processor
      class CommandLine < Base
        def on_header(h)
          @last = h.path
        end
      
        def process_all
          ok, errors = [], []
          begin
            each{}
            ok << @last
          rescue Exception => e
            errors << [@last, e]
          end while has_next_file?
          puts (["Processed successfully:"] + ok).join("\n") unless ok.empty?
          puts (["**** Processed with errors: ****"] + errors.map{|path, err| "#{path}: #{err}"}).join("\n") unless errors.empty?
        end
      end
    end
  end
end