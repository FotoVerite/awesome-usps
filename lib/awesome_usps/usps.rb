module AwesomeUSPS
  class USPS
    def initialize(username)
      @username = validate(username)
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end

    modules = %w(tracking gateway shipping delivery_and_signature_confirmation
                 service_standard open_distribute_priority
                 electric_merchandise_return express_mail address_verification
                 international_mail_labels)

    modules.each do |m|
      require File.join("awesome_usps", m)
      include "AwesomeUSPS::#{m.camelize}".constantize
    end
  end
end
