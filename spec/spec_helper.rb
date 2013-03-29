ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
require 'minitest/spec'
require 'minitest/autorun'

require 'discounter'

Bundler.require :default, :test
