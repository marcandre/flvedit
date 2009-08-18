require_relative "meta_data_maker"

module FLV
  module Edit
    module Processor

      # Update is a Processor class (see Base and desc)
      class Update < Base
        include Dispatcher
        desc ["Updates FLV with an onMetaTag event containing all the relevant information.",
              "If supplied, the information of the yaml file PATH will be added"],
              :param => {:name => "[PATH]"}
        def initialize(source=nil, options={})
          super
          @meta_data_maker = MetaDataMaker.new(source.clone, options)
        end
      
      
        def each
          return to_enum unless block_given?
          begin
            @meta_data_maker.each {}
          rescue Exception => e  # even if each throws, we better call super otherwise we won't be synchronized anymore!
            super rescue nil
            raise e
          else
            super
          end
        end
      
        absorb :on_meta_data, :on_last_second
        
        def on_header(header)
          dispatch_instead header, Tag.new(0, @meta_data_maker.meta_data)
        end
      end
    end
  end
end