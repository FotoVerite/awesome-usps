lib = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "awesome_usps/version"
require "awesome_usps/usps"

module AwesomeUSPS
  def self.new(*args)
    AwesomeUSPS::USPS.new(*args)
  end

  def self.logger
    @logger ||= (
      if defined?(Rails)
        Rails.logger
      else
        Logger.new(STDOUT)
      end
    )
  end
end
