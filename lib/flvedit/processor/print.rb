require_relative "printer"
module FLV
  module Edit
    module Processor

      # Print is a Processor class (see Base and desc)
      class Print < Base
        desc "Prints out the meta data"
        include Filter
        
        def before_filter
          @printer = Printer.new(options[:out])
        end

        def filter(tag)
          tag.debug(@printer) if tag.is? :onMetaData
        end
      end
    end
  end
end