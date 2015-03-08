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

  # Get non-filtered information
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.cloud_get_all(conn)
    servers_list = self.check_if_cached("instances_#{conn[0]}_#{conn[1][:cloud]}", false, conn, 'describe_instances')
    servers_list.each do |instances|
      instances['instances'].each do |i|
        Printer.print('debug', "Found instance: #{i.instance_id}", 3)
        hostname  = ""
        tags      = Array.new
        described_tags = self.check_if_cached("tags_#{conn[0]}_#{conn[1][:cloud]}_#{i.instance_id}", false, conn, 'describe_tags', i.instance_id)
      end
    end
    # ap servers_list
  end

  # Returns all the information
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.get_all_the_information
    Printer.print('debug', 'Trying to get information about all the instances', 3)
    $connections.each do |conn|
      if $params.cloud_given && conn[1][:cloud] == $params.cloud
        # Using only information from the cloud specified.
        Printer.print('debug', "Printing instances from specified cloud: #{$params.cloud}", 5)
        self.cloud_get_all(conn)
      elsif $params.account_given && conn[0] == $params.account
        # Displaying all the servers using specified account.
        Printer.print('debug', "Printing instances from specified account: #{$params.account}", 5)
        self.cloud_get_all(conn)
      elsif $params.region_given && conn[1][:region] == $params.region
        Printer.print('debug', "Printing instances from specified region: #{$params.region}", 5)
        self.cloud_get_all(conn)
      elsif $params.all == true
        # Display all the information from all accounts and clouds.
        # Heads up: It will take a while if you have more than 50 instances.
        Printer.print('debug', 'Printing instances from all the accounts and clouds', 5)
        self.cloud_get_all(conn)
      end
    end
  end

  # Caching results
  # ~~~~~~~~~~~~~~~
  # Using dummy file based cache to store all the results
  def self.check_if_cached(resource = 'describe_instances', flush = false,
    cloud_connector = nil, check_type = 'describe_instances', instance_id = nil)
    cloud_data = nil
    cache_dir = '/var/tmp'
    # Information is cached and we don't want to flush it.
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if flush == false && File.exist?("#{cache_dir}/mass-#{resource}.cache")
      Printer.print('debug', "Found information about #{resource} in cache.", 5)
      File.open("#{cache_dir}/mass-#{resource}.cache") do |f|
        cloud_data = Oj.load(f.read)
      end
      return cloud_data
    # Information isn't cached or we just flushed it.
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    else
      data_to_save = nil
      # List all the servers
      if check_type == 'describe_instances'
        if cloud_connector[1][:cloud] == 'aws'
          data_to_save = cloud_connector[1][:connector].describe_instances[0]
        end
      elsif check_type == 'describe_tags'
        if cloud_connector[1][:cloud] == 'aws'
          data_to_save = cloud_connector[1][:connector].describe_tags(:filters => [{ :name => 'resource-id', :values => [instance_id] }])[0]
        end
      end
      File.open("#{cache_dir}/mass-#{resource}.cache", 'w') do |f|
        Printer.print('debug', "Saving cache information for #{resource}", 5)
          f.write Oj.dump(data_to_save)
      end
      self.check_if_cached(resource, flush, cloud_connector, check_type)
    end
  end
end