module FLV
  module Edit  
    module Processor
      module Filter
        def each
          return to_enum unless block_given?
          before_filter
          catch :stop do
            source.each do |chunk|
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