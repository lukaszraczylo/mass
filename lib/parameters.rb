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
    if ( ! $params.filter && ! $params.cloud && ! $params.account  && ! $params.region )
      $params[:all] = true
    end
    # Gathering information
    Cloud.get_all_the_information

    if ( ! $params.ssh && ! $params.raw )
      Printer.print('debug', 'Printing out table with results.', 5)
      tp.set :max_width, 120
      tp $instances_data

    elsif ( $params.raw )
      Printer.print('debug', 'Printing out ";;" separated results.')
      $instances_data.each do |line|
        puts line.values.join(';;')
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
      opt :raw, "Printing out without tables, ';;' separated for easier parsing."
      opt :region, "Cloud account region to use", :type => :string
      opt :ssh, "Open SSH connection to all the results"
    end

    # Returning debug as it's the one whe are most interested in
    $debug = opts.debug.to_i
    return opts
  end
end