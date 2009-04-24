module FLV
  module Edit
    module Processor

      # Save is a Processor class (see Base and desc)
      class Save < Base
        desc "Saves the result to PATH", :param => {:class => String, :name => "PATH"}
        
        def each
          return to_enum unless block_given?
          @out = FLV::File::open(options[:save] || (h.path+".temp"), "w+b")
          super do |chunk|
            @out << chunk
            yield chunk
          end
        ensure
          @out.close
          finalpath = @out.path.sub(/\.temp$/, '')
          FileUtils.mv(@out.path, finalpath) unless finalpath == @out.path          
        end
      end
    end
  end
end