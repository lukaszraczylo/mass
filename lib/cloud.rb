# Cloud module
# ~~~~~~~~~~~~
#
# Module responsible for cloud operations. It's a proxy between you, mass and
# your cloud provider of choice. By default it enables

require 'aws-sdk'

module Cloud
  # Serves connection, returns hash of successful connections in format
  #   { 'provider_name', 'connector }'
  def self.connect
    # Iterating through all settings from the config file
    $config['provider_zones'].each do |provider|
      if provider[1]['cloud'].downcase == 'aws'
        connection = Aws::EC2::Client.new(
            :region             => provider[1]['region'],
            :access_key_id      => provider[1]['aws_access_key_id'],
            :secret_access_key  => provider[1]['aws_secret_access_key']
          )
      end
      Printer.print('debug', "Connected to #{provider[0]}\t cloud: #{provider[1]['cloud']}, region: #{provider[1]['region']}", 4)
      $connections.merge!( provider[0] => { :region => provider[1]['region'], :cloud => provider[1]['cloud'], :connector => connection } )
    end
  end
end