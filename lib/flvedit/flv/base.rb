module FLV
  # Common fonctionality to both FLV::Header, FLV::Tag & FLV::Body
  module Base
    def self.included(base)
      base.class_eval do
        include Packable
      end
    end
    
    # returns the instance methods
    # that are proper (i.e. not redefinitions)
    # and that don't require any argument.
    def getters(of=self)
      of.class.ancestors.
        map{|k| k.instance_methods(false)}.
        inject(:-).  # cute and tricky! remember that the first ancestor is of.class itself, so that's what we start with
        select{|m| of.class.instance_method(m).arity.between?(-1,0)}
    end
    
    def to_hash(attributes = getters)
      Hash[
        attributes.map do |a|
          a = a.to_s.delete("@").to_sym
          [a, send(a)]
        end
      ]
    end
    
    def is?(what)
      kn = self.class.name.downcase
      [kn, kn.sub("flv::","")].include?(what.to_s.downcase)
    end

    def size
      StringIO.new.packed.write(self)
    end
    
  end
  
end