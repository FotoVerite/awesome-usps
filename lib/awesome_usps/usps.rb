module AwesomeUSPS
  class USPS
    def initialize(username)
      @username = validate(username)
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
    include AwesomeUSPS::Tracking
    include AwesomeUSPS::Gateway
    include AwesomeUSPS::Shipping
    include AwesomeUSPS::DeliveryAndSignatureConfirmation
    include AwesomeUSPS::ServiceStandard
    include AwesomeUSPS::OpenDistrubutePriority
    include AwesomeUSPS::ElectricMerchandisReturn
    include AwesomeUSPS::ExpressMail
    include AwesomeUSPS::AddressVerification
    include AwesomeUSPS::InternationalMailLabels

  end
end
