# Configuration module
# ~~~~~~~~~~~~~~~~~~~~
#
# Manages checks and configuration parsing. Nothing fancy there.

module Configuration
  # Checking configuration
  def self.parse
    $params.config == nil ? config_file = ENV['HOME'] + '/.config.yaml' : config_file = $params.config
    if File.exist?(config_file)
      Printer.print('debug', "Configuration file exists - #{config_file}", 3)
      begin
        parsed_config = YAML.load_file(config_file)
        Printer.print('debug', "Configuration file is a parsable YAML file", 3)
        return parsed_config
      rescue
        Printer.print('error', 'Can\'t parse configuration file. Is it in YAML format?')
      end
    else
      Printer.print('error', 'Configuration file doesn\'t exist')
    end
  end
end