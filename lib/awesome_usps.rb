$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require "awesome_usps/version"
require "awesome_usps/usps"

module AwesomeUSPS
  def self.new(*args)
    AwesomeUSPS::USPS.new(*args)
  end
end
