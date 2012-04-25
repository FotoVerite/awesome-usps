require 'active_support/core_ext/string'

module AwesomeUSPS
  lib_path = File.expand_path(File.dirname(__FILE__))
  modules = Dir[File.join(lib_path, "*.rb")].map { |f| File.basename f, '.rb' }
  modules.each do |m|
    autoload m.camelize.to_sym, File.join("awesome_usps", m)
  end

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
