require_relative "meta_data_maker"

module FLV
  module Edit
    module Processor
      class Update < Base
        include Dispatcher
        desc "Updates FLV with an onMetaTag event"
        def initialize(source=nil, options={})
          super
          @meta_data_maker = MetaDataMaker.new(source.dup, options)
        end
      
        def each(&block)
          return to_enum unless block_given?
          @meta_data_maker.each {}
        ensure  # even if each throws, we better call super otherwise we won't be synchronized anymore!
          super
        end
      
        absorb :on_meta_data, :on_last_second
        
        def on_header(header)
          dispatch_instead header, Tag.new(0, @meta_data_maker.meta_data)
        end
      end
    end
  end
end