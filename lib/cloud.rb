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

  # Returns all the information
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.get_all_the_information
    Printer.print('debug', 'Trying to get information about all the instances', 3)
    ap $params
    $connections.each do |conn|
      if $params.cloud_given && conn[1][:cloud] == $params.cloud
        # Using only information from the cloud specified.
        Printer.print('debug', "Printing instances from specified cloud: #{$params.cloud}", 5)
      elsif $params.account_given && conn[0] == $params.account
        # Displaying all the servers using specified account.
        Printer.print('debug', "Printing instances from specified account: #{$params.account}", 5)
      elsif $params.all == true
        # Display all the information from all accounts and clouds.
        # Heads up: It will take a while if you have more than 50 instances.
        Printer.print('debug', 'Printing instances from all the accounts and clouds', 5)
      end
    end
  end

  # Caching results
  # ~~~~~~~~~~~~~~~
  # Using dummy file based cache to store all the results
  def self.cache_results(resource = 'describe_instances', flush = false,
    cloud_connector = nil, check_type = 'describe_instances', instance_id = nil)
    cloud_data = nil
    cache_dir = '/var/tmp'
    # Information is cached and we don't want to flush it.
    if flush == false && File.exists("#{cache_dir}/mass-#{resource}.cache")
      Printer.print('debug', "Found information about #{resource} in cache.", 5)
    # Information isn't cached or we just flushed it.
    else
      File.open("#{cache_dir}/mass-#{resource}.cache", 'w') do |f|
        Printer.print('debug', "Saving cache information for #{resource}", 5)
        # f.write Oj.dump(data_to_save)
      end
      self.cache_results(resource, flush, cloud_connector, check_type)
    end
  end
end