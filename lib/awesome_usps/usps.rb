lib_path = File.expand_path(File.dirname(__FILE__))
modules = Dir[File.join(lib_path, "*.rb")].map { |f| File.basename f }
modules.each do |m|
  require File.join("awesome_usps", m)
end

module AwesomeUSPS
  class USPS
    def initialize(username)
      @username = validate(username)
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
  end
end
