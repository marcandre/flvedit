module FLV
  module Edit
    module Processor
      class Head < Base
        desc "Processes only the first NB tags.", :param => {:class => Integer, :name => "NB"}, :shortcut => "n"

        def each
          count = options[:head]
          source.each_with_index do |chunk, i|
            yield chunk
            break if i >= count # inclusive because we're not counting the header
          end
        end
        
      end
    end
  end
end