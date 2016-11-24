begin
  require 'bundler/setup'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'opto'
