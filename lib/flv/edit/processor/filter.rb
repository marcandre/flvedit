module FLV
  module Edit  
    module Processor
      
      # Basic processors can include Filter which
      # provides a pretty simple #each.
      # It will call #before_filter then
      # #filter(chunk) for each chunk.
      # If #filter returns +:skip+, the chunk won't be yielded
      # #filter can also stops altogether the processing
      # of the current source by calling #stop. 
      module Filter
        def each
          return to_enum unless block_given?
          before_filter
          catch :stop do
            super do |chunk|
              yield chunk unless filter(chunk) == :skip
            end
          end
        end
      protected
        def before_filter
        end
        def stop
          throw :stop
        end
        
      end #module Filter
    end #module Processor
  end #module Edit
end #module FLV