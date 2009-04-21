module FLV
  module Edit
    module Processor
      class Head < Base
        desc "Processes only the first NB tags.", :param => {:class => Integer, :name => "NB"}, :shortcut => "n"
        def on_header(header)
          @count = self.options[:head]
        end

        def on_tag(tag)
          throw :stop if (@count -= 1) < 0
        end
      end
    end
  end
end