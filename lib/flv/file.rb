module FLV
  module File
    def each(*arg, &block)
      return super unless arg.empty?
      return to_enum unless block_given?
      h= read(Header)
      yield h
      super(Tag, &block)
    end

    def self.open(*arg)
      file = ::File.open(*arg)
      begin
        file = return_value = file.packed.extend(File)
      rescue Exception
        file.close
        raise
      end
      begin 
        return_value = yield(file) 
      ensure 
        file.close 
      end if block_given? 
      return_value 
    end

    def self.read(portname, *arg)
      open(portname) do |f|
        return f.to_a if arg.empty?
        n, offset = arg.first, arg[1] || 0
        f.each.first(n+offset)[offset, offset+n-1]
      end
    end
    
    def self.foreach(portname, *, &block)
      open(portname) do |f|
        f.each(&block)
      end
    end
  end
end