$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'yaml'
require 'rspec'

# Project specific modules
require 'printer'
require 'parameters'
require 'configuration'


RSpec.configure do |c|
  c.tty = true
  c.color = true
  c.fail_fast = true
  c.formatter = :documentation
end

$params = Parameters.parse
$config = Configuration.parse