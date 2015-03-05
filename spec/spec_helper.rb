$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# $LOAD_PATH.unshift(File.dirname(__FILE__)+'/../lib/')

require 'yaml'
require 'rspec'

# Project specific modules
require 'printer'
require 'parameters'
require 'configuration'


RSpec.configure do |c|
  c.fail_fast = true
end

$params = Parameters.parse
$config = Configuration.parse