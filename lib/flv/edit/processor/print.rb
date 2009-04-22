require_relative "printer"
module FLV
  module Edit
    module Processor
      class Print < Base
        desc "Prints out meta data to stdout"
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