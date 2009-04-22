module FLV
  module Edit  
    module Processor
      class Base
        include Enumerable
        attr_reader :options

        def initialize(source=nil, options={})
          @options = options.reverse_merge(:out => STDOUT)
          @source = source
          setup
        end

        def rewind
          source.rewind
        end

        def each_source(&block)
          source.each_source(&block)
        end

        def each(&block)
          source.each(&block)
        end
      
        def process_all
          each_source{each{}}
        end

      protected
        attr_reader :source
        
        def setup
        end
        
        def self.desc(text, options = {})
          registry << [self, text, options]
        end
    
        def self.registry # :nodoc:
          @@registry ||= []
        end
    
      end #class Base

      def self.chain(chain_classes, options = {})
        next_chain_class = chain_classes.pop
        next_chain_class.new(chain(chain_classes, options), options) if next_chain_class
      end
    end #module Processor
  end #module Edit
end #module FLV