module FLV
  module Edit
    module Processor

      # Head is a Processor class (see Base and desc)
      class Head < Base
        desc "Processes only the first NB tags.", :param => {:class => Integer, :name => "NB"}, :shortcut => "n"

        def each
          count = options[:head]
          super do |chunk|
            yield chunk
            break if (count -= 1) < 0 # after the yield because we're not counting the header
          end
        end
        
      end
    end
  end
end