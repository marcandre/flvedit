require 'test/unit' 
require 'rubygems'
require 'backports'
require_relative '../lib/flv/edit'
require 'shoulda'
require 'mocha'

SHORT_FLV = File.dirname(__FILE__) + "/fixtures/short.flv"
TEMP_FLV = File.dirname(__FILE__) + "/fixtures/short_temp.flv"
