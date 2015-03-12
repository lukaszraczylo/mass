# Parameters module
# ~~~~~~~~~~~~~~~~~
#
# Module responsible for parsing parameters and calling appropriate functions

require 'trollop'
require 'table_print'

module Parameters
  # Actions based on parameters
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.act
    # If no parameters specified it defaults to --all
    if ( ! $params.filter_given && ! $params.cloud && ! $params.account  && ! $params.region )
      $params[:all] = true
    end
    # Gathering information
    Cloud.get_all_the_information

    if ( ! $params.ssh_given && ! $params.raw_given )
      Printer.print('debug', 'Printing out table with results.', 5)
      tp.set :max_width, $params.width
      tp $instances_data

    elsif ( $params.ssh_given )
      cmd = ""
      $instances_data.each do |instance|
        # Using external IP to connect to host
        if $params.external_given && instance[:public_ip] != nil
          cmd << " #{instance[:public_ip]}"
          Printer.print('debug', "Found a public ip #{instance[:public_ip]} for instance #{instance[:instance_id]}", 5)
        elsif $params.internal_given
          cmd << " #{instance[:private_ip]}"
          Printer.print('debug', "Found a private ip #{instance[:private_ip]} for instance #{instance[:instance_id]}", 5)
        else
          Printer.print('warning', "Instance #{instance[:instance_id]} doesn't have external IP assigned. Ignoring.")
        end
      end
      Printer.print('debug', "Starting CsshX with following hosts: #{cmd}")
      Printer.print('success', "Please check your terminal ( no iTerm2 ) window for ssh sessions.")
      `csshx --sorthosts #{cmd}`

    elsif ( $params.raw_given )
      Printer.print('debug', "Printing out \"#{$params.raw}\" separated results.")
      $instances_data.each do |line|
        puts line.values.join($params.raw)
      end
    end
  end

  # Parsing parameters
  # ~~~~~~~~~~~~~~~~~~
  def self.parse
    opts = Trollop::options do
      version "mass #{$version} (c) 2015 Lukasz Raczylo <lukasz@raczylo.com>\nVisit https://github.com/lukaszraczylo/mass for source code"
      banner <<-EOS
Mass is a simple tool for DevOps created to make cloud infrastructure management easy.
Usage:
      $ mass [options]

where [options] are:
EOS
      opt :all, "Show all the accounts, no filtering, no accounts and clouds separation."
      opt :account, "Cloud account set in your configuration file", :type => :string
      opt :cloud, "Cloud service you'd like to use. Must comply with your settings file.", :type => :string
      opt :config, "Configuration file path. If non specified - using ~/.config.yaml", :type => :string
      opt :debug, "Debug and its level. Lower debug level equals to less information printed.", :default => 0
      opt :filter, "Filtering results. Please refer to README.md for filters documentation.", :type => :string
      opt :raw, "Printing out without tables, separator of your choice.", :type => :string, :default => ';;'
      opt :region, "Cloud account region to use", :type => :string
      opt :external, "Use external IP ( for SSH and listing )", :default => false
      opt :internal, "Use internal IP ( for SSH )", :default => true
      opt :ssh, "Open SSH connection to all the results"
      opt :update, "Flush cache for specified result set", :default => false
      opt :width, "Max columng width", :type => :integer, :default => 120
    end

    # Returning debug as it's the one whe are most interested in
    $debug = opts.debug.to_i
    return opts
  end
end