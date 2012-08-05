require 'nokogiri'
require 'net/https'
require 'awesome_usps/package'
require 'awesome_usps/location'
require 'awesome_usps/international_item'
require 'awesome_usps/tracking'
require 'awesome_usps/shipping'
require 'awesome_usps/delivery_and_signature_confirmation'
require 'awesome_usps/service_standard'
require 'awesome_usps/open_distrubute_Priority'
require 'awesome_usps/electric_merchandis_return'
require 'awesome_usps/express_mail'
require 'awesome_usps/address_verification'
require 'awesome_usps/international_mail_labels'
require 'awesome_usps/gateway'
require 'awesome_usps/canned_tests'
require 'awesome_usps/awesome_usps_errors'

include AwesomeUsps

module AwesomeUsps
  class USPS
    def initialize(username)
      @username = username
    end

    include Tracking
    include Shipping
    include DeliveryAndSignatureConfirmation
    include ServiceStandard
    include OpenDistrubutePriority
    include ElectricMerchandisReturn
    include ExpressMail
    include AddressVerification
    include InternationalMailLabels
    include Gateway
    include CannedTests


    def image_mime_type(image_type)
        if image_type == "PDF"
            image_type = "application/pdf"
        else
            image_type = "image/#{image_type.downcase}"
        end
    end

  end
end