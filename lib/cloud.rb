# Cloud module
# ~~~~~~~~~~~~
#
# Module responsible for cloud operations. It's a proxy between you, mass and
# your cloud provider of choice. By default it enables

require 'aws-sdk'

class Hash
  def grep(pattern)
    inject([]) do |res, kv|
      res << kv if kv[0] =~ pattern or kv[1] =~ pattern
      res
    end
  end
end

module Cloud
  # Serves connection, returns hash of successful connections in format
  #   { 'provider_name', 'connector }'
  def self.connect
    # Iterating through all settings from the config file
    $config['provider_zones'].each do |provider|
      if provider[1]['cloud'].nil?
        Printer.print('error', "Invalid config file for #{provider[0]} - missing cloud definition.")
      end
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

  # Get filtered information
  # ~~~~~~~~~~~~~~~~~~~~~~~~
  def self.cloud_get_filtered(conn)
    self.cloud_get_all(conn)
    tmp_results = Array.new
    $instances_data.each do |i|
      checks_passed = 0
      all_the_filters = $params.filter.split(',,')
      all_the_filters.each do |f|
        begin
          if i[f.split('::')[0].to_sym] =~ Regexp.new(f.split('::')[1])
            checks_passed += 1
            Printer.print('debug', "Found instance #{i[:instance_id]} matching filter.", 5)
          end
        rescue
          Printer.print('debug', "Something went wrong with checks of #{i[:instance_id]}", 5)
        end
      end
      if checks_passed == all_the_filters.size
        tmp_results.push(i)
      end
    end
    $instances_data = tmp_results.uniq
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
        env_tags  = Array.new
        app_tags  = Array.new
        described_tags = self.check_if_cached("tags_#{conn[0]}_#{conn[1][:cloud]}_#{i.instance_id}", false, conn, 'describe_tags', i.instance_id)
        described_tags.each do |tag|
          if tag.key == "Name"
            hostname = tag.value.downcase
          elsif tag.key =~ /^env.*/
            env_tags.push(tag.value.downcase)
          elsif tag.key =~ /^app.*/
            app_tags.push(tag.value.downcase)
          else
            tags.push("#{tag.key.downcase}: #{tag.value.downcase}")
          end
        end
        # Joining collected tags
        if app_tags.length > 0
          tags.push("apps: #{app_tags.join(',')}")
        end
        if env_tags.length > 0
          tags.push("env: #{env_tags.join(',')}")
        end

        tmp_data = {
          :account          => conn[0],
          :hostname         => hostname,
          :instance_id      => i.instance_id,
          :status           => i.state.name,
          :instance_az      => i.placement.availability_zone,
          :size             => i.instance_type,
          :private_ip       => i.private_ip_address,
          :public_ip        => i.public_ip_address,
          :instance_tags    => tags.join(" / ")
        }
        $instances_data.push(tmp_data)
      end
    end
  end

  # Returns all the information
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.get_all_the_information
    Printer.print('debug', 'Trying to get information about all the instances', 3)
    $instances_data = Array.new
    $connections.each do |conn|
      if $params.cloud_given && conn[1][:cloud] == $params.cloud
        # Using only information from the cloud specified.
        Printer.print('debug', "Printing instances from specified cloud: #{$params.cloud}", 5)
        $params.filter_given ? self.cloud_get_filtered(conn) : self.cloud_get_all(conn)
      elsif $params.account_given && conn[0] == $params.account
        # Displaying all the servers using specified account.
        Printer.print('debug', "Printing instances from specified account: #{$params.account}", 5)
        $params.filter_given ? self.cloud_get_filtered(conn) : self.cloud_get_all(conn)
      elsif $params.region_given && conn[1][:region] == $params.region
        Printer.print('debug', "Printing instances from specified region: #{$params.region}", 5)
        $params.filter_given ? self.cloud_get_filtered(conn) : self.cloud_get_all(conn)
      elsif $params.all == true
        # Display all the information from all accounts and clouds.
        # Heads up: It will take a while if you have more than 50 instances.
        Printer.print('debug', "Printing instances from all the accounts and clouds for account: #{conn[0]}", 5)
        $params.filter_given ? self.cloud_get_filtered(conn) : self.cloud_get_all(conn)
      else
        Printer.print('debug', "Empty result set - there\'s nothing there.", 3)
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