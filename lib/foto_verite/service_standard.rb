module FotoVerite
  module ServiceStandard
    
    # Takes your package tracking number and returns information for the USPS web API
    def priority_mail_estimated_time(origin, destination, api_request="PriorityMailRequest")
      origin = orgin
      destination=destination
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      commit_service_standard_request(:priority_mail, 'PriorityMail', request , :live)
    end

    def standard_mail_estimated_time(origin, destination, api_request='StandardBRequest')
      origin = orgin
      destination=destination
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      gateway_commit(:standard, 'StandardB', request, :live)
    end

    def express_mail_commitment(origin, destination, date=nil, api_request='ExpressMailCommitmentRequest')
      xml_for_estimated_time_for_delivery(api_request, origin, destination, date)
      gateway_commit(:express, 'ExpressMailCommitment', request, :live)
    end

    def canned_standard_mail_estimated_time_test
      origin =  Location.new(  :zip5 => '4')
      destination = Location.new( :zip5 => '4')
      api_request="StandardBRequest"
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      gateway_commit(:priority_mail, 'PriorityMail', request,  :test)
    end

    def canned_priority_mail_estimated_time_test
      origin =  Location.new(  :zip5 => '4')
      destination = Location.new( :zip5 => '4')
      api_request="PriorityMailRequest"
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      gateway_commit(:standard, 'StandardB',  request,  :test)
    end

    def canned_express_mail_commitment_test
      origin= Location.new(  :zip5 =>'20770')
      destination=Location.new( :zip5 =>'11210')
      date = '05-Aug-2004'
      api_request = 'ExpressMailCommitmentRequest'
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination, date)
      gateway_commit(:express, 'ExpressMailCommitment', request,  :test)
    end

    # XML from a straight string.
    def xml_for_estimated_time_for_delivery(api_request, origin, destination, date=nil)
      xm = Builder::XmlMarkup.new
      xm.tag!(api_request, "USERID"=>"#{@username}") do
        xm.OriginZIP(origin.zip5)
        xm.DestinationZIP(destination.zip5)
        if api_request == 'ExpressMailCommitmentRequest'
          xm.Date(date)
        end
      end
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse_service(xml)
      event_list = []
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        return  parse = (Hpricot.parse(xml)/:days).inner_html
      end
    end

    def parse_express(xml)
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        i= 0
        location_list = []
        (Hpricot.parse(xml)/:location).each do |location|
          i+=1
          h = {}
          location.children.each {|elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank?}
          location_list << h
        end
        return   location_list
      end
    end

  end
end
