module FLV
  module Edit  
    module Processor
      class Reader < Base
        def initialize(*)
          super
          rewind
          raise "Oups, Filenames were #{@options[:files].inspect}" if @options[:files].include? nil
          raise "Please specify at least one filename" if @options[:files].empty?
        end

        def has_next_file?
          @to_process > 0
        end
  
        def rewind
          @to_process = @options[:files].length
        end

        def process_next_file
          raise IndexError, "No more filenames to process" unless has_next_file?
          @to_process -= 1
          FLV::File.open(@options[:files][-1- @to_process]) do |f|
            dispatch_chunks(f)
          end
        end
      end
    end
  end
end