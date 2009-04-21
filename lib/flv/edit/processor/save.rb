module FLV
  module Edit
    module Processor
      class Save < Base
        desc "Saves the result to PATH", :param => {:class => String, :name => "PATH"}
        def process_next_file
          super
        ensure
          if @out
            @out.close
            finalpath = @out.path.sub(/\.temp$/, '')
            FileUtils.mv(@out.path, finalpath) unless finalpath == @out.path
          end
        end

        def on_header(h)
          @out = FLV::File::open(options[:save] || (h.path+".temp"), "w+b")
          @out << h
        end
        
        def on_tag(t)
          @out << t
        end
      end
    
    end
  end
end