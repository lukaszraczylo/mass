require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Configuration' do
  it 'have credentials' do
    Configuration.parse
  end
end