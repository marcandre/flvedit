# encoding: utf-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

# bench
begin
  desc "Benchmark"
  task :bench do
    require File.dirname(__FILE__)+"/lib/flv/edit"
    SHORT_FLV = File.dirname(__FILE__) + "/test/fixtures/short.flv"
    require 'benchmark' 
    include Benchmark
    runner = FLV::Edit::Runner.new([SHORT_FLV, SHORT_FLV, '--Join'])
    bm(6) do |x| 
      x.report("test") { 20.times { runner.run } } 
    end 
  end
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "flvedit"
    gem.summary = "Command line tool & library to handle FLV files"
    gem.email = "github@marc-andre.ca"
    gem.homepage = "http://github.com/marcandre/flvedit"
    gem.description = <<-EOS
      flvedit allows you to:
      * compute metadata for FLV files
      * merge, split or cut FLVs
      * insert / remote cue points or other events
      
      flvedit is meant as a replacement for FLVTool2, FLVMeta, FLVTool++
      It can be used as a command line tool or as a Ruby library.
    EOS
    gem.authors = ["Marc-André Lafortune"]
    gem.rubyforge_project = "flvedit"
    gem.add_dependency "packable", ">=1.2"
    gem.add_dependency "backports"
    gem.has_rdoc = true
    gem.rdoc_options << '--title' << 'FLV::Edit' <<
                           '--main' << 'README.rdoc' <<
                           '--line-numbers' << '--inline-source'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end unless RUBY_VERSION >= "1.9"

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'packable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rcov::RcovTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :rcov

# stats
begin
  gem 'rails'
  require 'code_statistics'
  namespace :spec do
    desc "Use Rails's rake:stats task for a gem"
    task :statsetup do
      class CodeStatistics
        def calculate_statistics
          @pairs.inject({}) do |stats, pair|
            if 3 == pair.size
              stats[pair.first] = calculate_directory_statistics(pair[1], pair[2]); stats
            else
              stats[pair.first] = calculate_directory_statistics(pair.last); stats
            end
          end
        end
      end
      ::STATS_DIRECTORIES = [['Libraries',   'lib',  /.(sql|rhtml|erb|rb|yml)$/],
                   ['Tests',     'test', /.(sql|rhtml|erb|rb|yml)$/]]
      ::CodeStatistics::TEST_TYPES << "Tests"
    end
  end
  desc "Report code statistics (KLOCs, etc) from the application"
  task :stats => "spec:statsetup" do
    CodeStatistics.new(*STATS_DIRECTORIES).to_s
  end
rescue Gem::LoadError => le
  task :stats do
    raise RuntimeError, "‘rails’ gem not found - you must install it in order to use this task.n"
  end
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do
    
    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]
    
    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/flvedit/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end
