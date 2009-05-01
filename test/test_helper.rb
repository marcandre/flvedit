require 'test/unit' 
require 'rubygems'
require 'backports'
require 'shoulda'
require 'mocha'
require_relative '../lib/flvedit'

SHORT_FLV = File.dirname(__FILE__) + "/fixtures/short.flv"
TEMP_FLV = File.dirname(__FILE__) + "/fixtures/short_temp.flv"
