module FLV
  module Edit  
    module Processor
      # Base is the base class for all Processors.
      # Processors are used to process FLV files.
      # A FLV file can be seen as an enumeration of chunks, the first one being a Header and the following ones
      # a series of Tags with different types of bodies: Audio, Video or Event.
      # A Processor acts as an IO operation on such enumerations.
      # They therefore take an enumeration of chunks as input and their output is similarly an enumeration of chunks.
      # They can thus be chained together at will.
      #
      # For example:
      #   FLV::File.open("x.flv") do |f|
      #     Debug.new(Cut.new(f, :cut => "1m-")).first(10)
      #   end
      #   # ==> reads the file, skips the first minute, prints and returns the first 10 chunks
      #
      # Processors acts as Enumerable, but #each, in that context, is an enumeration of chunks
      # for one single file. Some processors act as more than one such enumeration (Reader, Split)
      # To go through all, call #each_source or #process_all
      #
      class Base
        include Enumerable
        attr_reader :options

        # Create a new processor, using the given +source+ and +options+ hash.
        # Valid +options+ depend on the class of Processor.
        def initialize(source=nil, options={})
          @options = options.reverse_merge(:out => STDOUT)
          @source = source
        end

        # Calls the given block once for each source
        def each_source(&block)
          raise "There is no source for #{self}" unless source
          source.each_source(&block)
        end

        # Calls the given block once for each chunck, passing that chunk as argument
        def each(&block)
          raise "There is no source for #{self}" unless source
          source.each(&block)
        end
      
        # Simple utility going through each chunk of each source
        def process_all
          each_source{ each{} }
        end

      protected
        attr_reader :source
        
        # Processors can be made directly accessible to the command line by calling #desc
        # with a description.
        # Options are:
        # * :shortcut => "x" (defaults to first letter of processor)
        # * :param => pass a hash if the command line should accept a parameter:
        #   * :class => class of the parameter (defaults to String)
        #   * :name => name of parameter, surrounded with [] if optional (defaults to the name of the class)
        def self.desc(text, options = {})
          registry << [self, text, options]
        end
    
        def self.registry # :nodoc:
          @@registry ||= []
        end
    
      end #class Base

      # Utility function to create a chain of Processors.
      # Example:
      #   chain(Update, Debug, Cut, options)
      #   # ==> Update.new(Debug.new(Cut.new(options),options),options)
      def self.chain(chain_classes, options = {})
        next_chain_class = chain_classes.pop
        next_chain_class.new(chain(chain_classes, options), options) if next_chain_class
      end
    end #module Processor
  end #module Edit
  
  module File
    # A file acts as a single source, so...
    def each_source
      yield
    end
  end
end #module FLV