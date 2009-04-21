# encoding: utf-8
require 'optparse'

module FLV
  module Edit
    class Options
      attr_reader :commands, :options
      def initialize(argv)
        @commands, @options = parse(argv)
      end
      
      def to_a
        [@commands, @options]
      end
      
    private
      def parse(argv)
        commands = []
        options = {}
        parser = OptionParser.new do |parser|
          parser.banner = banner
          parser.separator ""
          parser.separator "Commands:"
          Processor::Base.registry.sort_by(&:to_s).
            each do |command, desc, cmd_opt|
              name = command.name.split('::').last.downcase
              option = name.downcase.to_sym
              shortcut = cmd_opt[:shortcut] || name[0..0]
              if param = cmd_opt[:param]
                name << " " << (param[:name] || param[:class].to_s.upcase)
                desc = [param[:class], *desc]  if param[:class]
              end
              parser.on("-#{shortcut}", "--#{name}", *desc) do |v|
                options[option] = v
                commands << command
              end
            end
           
          parser.separator ""
          parser.separator "Switches:"
          [
            [:keyframe_mode,      "Keyframe mode slides on_cue_point(navigation) tags added by the",
                                  "add command to nearest keyframe position"]
          ].each do |switch, *desc|
            shortcut = desc.first.is_a?(Symbol) ? desc.shift.to_s : switch.to_s[0..0]
            full = desc.first.is_a?(Class) ? "--#{switch.to_s} N" : "--#{switch.to_s}"
            parser.on("-#{shortcut}", full, *desc) { |v| options[switch] = v }
          end
              
          parser.separator "Common:"
          parser.on("-h", "--help", "Show this message") {}
          parser.on("--version", "Show version") do
            puts "Current version: #{FLV::Edit.version}"
            exit
          end
          
          parser.separator ""
          parser.separator "flvedit (#{FLV::Edit.version}), copyright (c) 2009 Marc-André Lafortune"
          parser.separator "This program is published under the BSD license."
        end
        options[:files] = parser.parse!(argv)
        if commands.empty?
          puts parser
          exit
        end
        return commands, options
      end
      
      def banner
        <<-EOS
Usage: flvedit#{(RUBY_PLATFORM =~ /win32/) ? '.exe' : ''} [--input] files --processing --more_processing ... [--save [PATH]]
******
*NOTE*: THIS IS NOT A STABLE RELEASE. API WILL CHANGE!
******
flvedit will apply the given processing to the input files. 

Examples:
  # Printout of the first 42 tags:
    flvedit example.flv --debug 42

  # Extract the first 2 seconds of a.flv and b.flv, join them and update the meta data.
    flvedit a.flv b.flv --cut 0-2 --join --update --save out.flv

Option formats:
  TIMESTAMP:  Given in seconds with decimals for fractions of seconds.
              Use 'h' and 'm' or ':' for hours and minutes separators.
  Examples:   1:00:01 (for 1 hour and 1 second), 1h1 (same),
              2m3.004 (2 minutes, 3 seconds and 4 milliseconds), 123.004 (same)
  RANGE:      Expressed as BEGIN-END, where BEGIN or END are timestamps
              that can be let empty for no limit
  Examples:   1m-2m (second minute), 1m- (all but first minute), -1m (first minute)
  RANGE/TS:   RANGE or TIMESTAMP.
        EOS
        #s.split("\n").collect!(&:strip).join("\n")
      end
    end
  end
end

#todo: explicit Input command
#todo: conditions for implicit Save
  
        # options[:metadatacreator] = "inlet media FLVTool2 v#{PROGRAMM_VERSION.join('.')} - http://www.inlet-media.de/flvtool2"
        # options[:metadata] = {}

          # when /^-([a-zA-Z0-9]+?):(.+)$/
          #   options[:metadata][$1] = $2
          # when /^-([a-zA-Z0-9]+?)#([0-9]+)$/
          #   options[:metadata][$1] = $2.to_f
          # when /^-([a-zA-Z0-9]+?)@(\d{4,})-(\d{2,})-(\d{2,}) (\d{2,}):(\d{2,}):(\d{2,})$/
          #   options[:metadata][$1] = Time.local($2, $3, $4, $5, $6, $7)
        #   when /^([^-].*)$/
        #     if options[:in_path].nil? 
        #       options[:in_path] = $1
        #       if options[:in_path].downcase =~ /stdin|pipe/
        #         options[:in_pipe] = true
        #         options[:in_path] = 'pipe'
        #       else
        #         options[:in_path] = File.expand_path( options[:in_path] )
        #       end
        #     else
        #       options[:out_path] = $1
        #       if options[:out_path].downcase =~ /stdout|pipe/
        #         options[:out_pipe] = true
        #         options[:out_path] = 'pipe'
        #       else
        #         options[:out_path] = File.expand_path( options[:out_path] )
        #       end
        #     end
        #   end
        # end
    
  
      # def self.validate_options( options )
      #    if options[:commands].empty?
      #      show_usage
      #      exit 0
      #    end
      #    
      #    options[:commands].each do |command|  
      #      case command
      #      when :print
      #        if options[:out_pipe]
      #          throw_error "Could not use print command in conjunction with output piping or redirection"
      #          exit 1
      #        end
      #      when :debug
      #        if options[:out_pipe]
      #          throw_error "Could not use debug command in conjunction with output piping or redirection"
      #          exit 1
      #        end
      #      when :help
      #        show_usage
      #        exit 0
      #      when :version
      #        show_version
      #        exit 0
      #      end
      #    end
      #    options
      #  end
      #  