module FLV
  module Edit  
    module Processor

      # Reader is a Processor class (see Base) which use <tt>options[:files]</tt> to generate
      # its sources (instead of the passed +source+ which should be nil)
      class Reader < Base
        def initialize(*)
          super
          raise "Invalid filenames: #{options[:files].inspect}" unless options[:files].all?
          raise "Please specify at least one filename" if options[:files].empty?
          raise NotImplemented, "Reader can't have a source (other than options[:files])" if source
          rewind_source
        end

        def each_source
          return to_enum(:each_source) unless block_given?
          rewind_source
          yield until @sources.empty?
        end
        
        def each
          p "Opening #{@sources.first}"
          FLV::File.open(@sources.shift) do |f|
            @source = f
            begin
              super
            rescue EOFError
              p "*** Warning: unexpected EOF for file #{f.path}"
            end
          end
        end
        
        def rewind_source
          @sources = options[:files].dup
        end
      end
    end
  end
end