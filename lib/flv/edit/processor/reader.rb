module FLV
  module Edit  
    module Processor
      class Reader < Base
        def setup
          rewind
          raise "Oups, Filenames were #{options[:files].inspect}" if options[:files].include? nil
          raise "Please specify at least one filename" if options[:files].empty?
        end

        def each_source
          return to_enum(:each_source) unless block_given?
          rewind
          yield while @to_process > 0
        end
          
        def rewind
          @to_process = options[:files].length
        end

        def each(&block)
          return to_enum unless block_given?
          raise IndexError, "No more files to process" unless @to_process > 0
          @to_process -= 1
          FLV::File.open(options[:files][-1- @to_process]) do |f|
            f.each(&block)
          end
        end
      end
    end
  end
end