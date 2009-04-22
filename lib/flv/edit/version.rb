module FLV
  module Edit
    FILE = ::File.dirname(__FILE__) + '/../../../VERSION.yml'
    
    class Version < Struct.new(:major, :minor, :patch) # :nodoc:
      def to_s
        "#{major}.#{minor}.#{patch}"
      end
    end
    
    def self.version
      Version.new(*YAML.load_file(FILE).values_at('major','minor','patch'))
    end
  end
end