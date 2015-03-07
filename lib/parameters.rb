# Parameters module
# ~~~~~~~~~~~~~~~~~
#
# Module responsible for parsing parameters and calling appropriate functions

require 'trollop'

module Parameters
  def self.parse
    # Parsing parameters
    # ~~~~~~~~~~~~~~~~~~
    opts = Trollop::options do
      version "mass #{$version} (c) 2015 Lukasz Raczylo <lukasz@raczylo.com>\nVisit https://github.com/lukaszraczylo/mass for source code"
      banner <<-EOS
Mass is a simple tool for DevOps created to make cloud infrastructure management easy.
Usage:
      $ mass [options]

where [options] are:
EOS
      opt :config, "Configuration file path. If non specified - using ~/.config.yaml", :type => :string
      opt :filter, "Filtering results. Please refer to README.md for filters documentation.", :type => :string
      opt :debug, "Debug and its level. Lower debug level equals to less information printed.", :default => 0
    end

    # Returning debug as it's the one whe are most interested in
    $debug = opts.debug.to_i
    return opts
  end
end