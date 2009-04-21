require_relative "printer"
module FLV
  module Edit
    module Processor
      class Print < Base
        desc "Prints out meta data to stdout"
        def on_meta_data(tag)
          tag.debug(Printer.new(stdout))
        end
      end
    end
  end
end