require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Configuration' do
  it 'exists and have credentials' do
    $ret = Configuration.parse
  end

  it 'contains hash of configuration' do
    expect($ret.class).to be Hash
  end
end