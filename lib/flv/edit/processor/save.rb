module FLV
  module Edit
    module Processor
      class Save < Base
        desc "Saves the result to PATH", :param => {:class => String, :name => "PATH"}
        
        def each_source
          return to_enum(:each_source) unless block_given?
          @out = FLV::File::open(options[:save] || (h.path+".temp"), "w+b")
          super
        ensure
          @out.close
          finalpath = @out.path.sub(/\.temp$/, '')
          FileUtils.mv(@out.path, finalpath) unless finalpath == @out.path
        end
        
        def each
          return to_enum unless block_given?
          source.each do |chunk|
            @out << chunk
            yield chunk
          end
        end
      end
    end
  end
end