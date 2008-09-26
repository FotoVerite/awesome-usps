module FotoVerite
  module Gateway

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAIN ='testing.shippingapis.com'
    TEST_RESOURCE = '/ShippingAPITest.dll'

    SSL_DOMAIN = 'secure.shippingapis.com'
    SSL_RESOURCE = '/ShippingAPI.dll'

    PARSE_METHOD = {
      :verify_address => 'parse_address_information',
      :zip_lookup => 'parse_address_information',
      :city_state_lookup => 'parse_address_information',
      :us_rates => 'parse_us',
      :world_rates => 'parse_world',
      :delivery => "parse_confirmation_label",
      :delivery_confirmation_certify => "parse_confirmation_label",
      :signature => "parse_confirmation_label",
      :signature_confirmation_certify => "parse_confirmation_label",
      :merchandise_return => "parse_merch_return_label",
      :merchandise_return_certify => "parse_merch_return_label",
      :express_mail_label => "parse_express_mail_label",
      :express_mail_label_certify => 'parse_express_mail_label',
      :priority_mail_certify => 'parse_internation_label',
      :priority_mail => 'parse_internation_label',
      :first_class_mail => "parse_internation_label",
      :first_class_mail_certify => 'parse_internation_label',
      :open_distrubute_priority => "parse_open_distrubute_priority",
      :open_distribute_priority_certify => "parse_open_distrubute_priority",
      :priority_mail => "parse_service",
      :standard => "parse_service",
      :express => 'parse_express',
      :tracking => 'parse_tracking'
    }


    RESPONSE = {
      :express_mail => "ExpressMailIntlResponse",
      :express_mail_certify => "ExpressMailIntlCertifyResponse",
      :priority_mail => "PriorityMailIntlResponse",
      :priority_mail_certify => "PriorityMailIntlCertifyResponse",
      :first_class_mail => "FirstClassMailIntlResponse",
      :first_class_mail_certify => "FirstClassMailIntlCertifyResponse"
    }

    def gateway_commit(action, api, request, http_request, image_type="PDF")
      retries = MAX_RETRIES
      begin
        url = URI.parse(url_path(http_request))
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => api, 'XML' => request})
        http = Net::HTTP.new(url.host, url.port)
        http.open_timeout = 2
        http.read_timeout = 2
        if http_request == :ssl
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = http.start do |http|
          http.request(req)
        end
      rescue Timeout::Error
        if retries > 0
          retries -= 1
          retry
        else
          RAILS_DEFAULT_LOGGER.warn "The connection to the remote server timed out"
          return "We appoligize for the inconvience but our USPS service is busy at the moment. To retry please refresh the browser"
        end
      rescue SocketError
        RAILS_DEFAULT_LOGGER.error "There is a socket error with USPS plugin"
        return "We appoligize for the inconvience but there is a problem with our server. To retry please refresh the browser"
      end
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        case  PARSE_METHOD[action]
        when 'parse_address_information'
          parse_address_information(response.body)
        when 'parse_confirmation_label'
          parse_confirmation_label(action, response.body, image_type)
        when 'parse_merch_return_label'
          parse_merch_return_label(response.body, image_type)
        when 'parse_express_mail_label'
          parse_express_mail_label(response.body, image_type)
        when  'parse_internation_label'
          parse_internation_label(response.body, image_type, RESPONSE[action])
        when 'parse_open_distrubute_priority'
          parse_open_distrubute_priority(response.body, image_type)
        when 'parse_express'
          parse_express(response.body)
        when 'parse_service'
          parse_service(response.body)
        when  'parse_world'
          parse_world(response.body)
        when 'parse_us'
          parse_us(response.body)
        when 'parse_tracking'
          parse_tracking(response.body)
        end
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
        return "USPS plugin settings are wrong #{response}"
      end
    end

    def url_path(action)
      case action
      when :test
        return  "http://#{TEST_DOMAIN}#{TEST_RESOURCE}"
      when :live
        return "http://#{LIVE_DOMAIN}#{LIVE_RESOURCE}"
      when :ssl
        return "https://#{SSL_DOMAIN}#{SSL_RESOURCE}"
      end
    end

  end
end
