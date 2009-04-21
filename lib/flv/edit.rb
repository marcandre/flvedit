require 'rubygems'
require 'backports'
require_relative '../flv'
require_relative 'edit/version'
require_relative 'edit/options'
require_relative 'edit/processor'
require_relative 'edit/runner'

#todo Change bin/flvedit
#todo Auto write to files
#todo Command Save no|false
#todo add & nearest keyframe & overwrite
#todo fix timestamps
#todo cut & nearest keyframe?
#todo print & xml/yaml & multiple files
#todo onLastSecond
#todo in|out pipe
#todo recursive?
#todo fix offset, both 24bit issue & apparent skips
#todo bug join & time for audio vs video