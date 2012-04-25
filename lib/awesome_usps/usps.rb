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

    %w(tracking gateway shipping delivery_and_signature_confirmation
       service_standard open_distribute_priority electric_merchandise_return
       espress_mail address_verification international_mail_labels).each do |m|
      include "AwesomeUSPS::#{m.camelize}".constantize
    end
  end
end
