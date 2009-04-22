require 'yaml'
require 'rexml/document'
require 'optparse'

module FLV
  module Edit
    module Processor

      class Add < Base
        include Dispatcher
        desc "Adds tags from the xml or yaml file PATH (default: tags.yaml/xml)", :param => {:name => "[PATH]"}
        
        def setup
          @add = (options[:add_tags] || read_tag_file).sort_by(&:timestamp)
        end
        
        def on_tag(tag)
          insert_before tag, @add
        end
        
        # def on_keyframe(tag)
        #   insert_before tag, @add_before_key_frame
        # end
        
      private
        def insert_before(tag, list_to_insert)
          stop_at = list_to_insert.find_index{|i| i.timestamp > tag.timestamp} || list_to_insert.length
          dispatch_instead(*(list_to_insert.slice!(0...stop_at) << tag))   if stop_at > 0
        end
      
        DEFAULT = ["tags.yaml", "tags.xml"]
        #todo: overwrite, navigation
        #todo: default event
        def read_tag_file
          filename = options[:add]
          DEFAULT.each{|fn| filename ||= fn if ::File.exists?(fn)}
          raise "You must either specify a tag file or have a file named #{DEFAULT.join(' or ')}" unless filename
          ::File.open(filename) {|f| read_tags(f)}
        end
        
        def read_tags(file)
          tags =
            unless file.path.downcase.end_with? ".xml"
              YAML.load(file)
            else
              xml = REXML::Document.new(file, :ignore_whitespace_nodes => :all) 
              xml.root.elements.to_a("metatag").map do |tag|
                {
                  :event => tag.attributes['event'],
                  :overwrite => tag.attributes['overwrite'],
                  :timestamp => (tag.elements['timestamp'].text rescue 0),
                  :navigation => (tag.elements['type'].text == "navigation" rescue false),
                  :arguments => Hash[tag.elements['parameters'].map{|param| [param.name, param.text]}]
                }
              end
            end
          tags = [tags] unless tags.is_a? Array
          tags.map do |info|
            info.symbolize_keys!
            Tag.new(info[:timestamp], Event.new(info[:event], info[:arguments]))
          end
        end
      end

    end
  end
end