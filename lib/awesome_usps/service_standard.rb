module AwesomeUsps
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
      origin =  Location.new(:zip5 => '4')
      destination = Location.new(:zip5 => '4')
      api_request="StandardBRequest"
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      gateway_commit(:priority_mail, 'StandardB', request,  :test)
    end

    def canned_priority_mail_estimated_time_test
      origin =  Location.new(  :zip5 => '4')
      destination = Location.new( :zip5 => '4')
      api_request="PriorityMailRequest"
      request = xml_for_estimated_time_for_delivery(api_request, origin, destination)
      gateway_commit(:standard, 'PriorityMail',  request,  :test)
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
       builder = Nokogiri::XML::Builder.new do |xm|
        xm.send("#{api_request}", "USERID"=>"#{@username}") do
          #BECAUSE USPS IS SO FUCKING STUPID IT NEEDS DIFFERENT FUCKING TAGS FOR ORIGIN AND DESTINATION BASED ON API WHICH ARE EITHER CAPITALIZED AT THE END OR NOT. FUCKING A. 
          if api_request == 'ExpressMailCommitmentRequest'
            xm.OriginZIP(origin.zip5)
            xm.DestinationZIP(destination.zip5)
            xm.Date(date)
          else
            xm.OriginZip(origin.zip5)
            xm.DestinationZip(destination.zip5)
          end
        end
      end
      builder.doc.root.to_xml
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse_service(xml)
      doc = Nokogiri::XML(xml)
      raise(USPSResponseError, doc.search('Description').inner_html) unless doc.xpath("Error").empty?
      doc.search("Days").inner_html
    end

    def parse_express(xml)
      doc = Nokogiri::XML(xml)
      raise(USPSResponseError, doc.search('Description').inner_html) unless doc.xpath("Error").empty?

      i= 0
      location_list = []
      doc.search('Location').each do |location|
        i+=1
        h = {}
        location.children.each {|elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.empty?}
        location_list << h
      end
      return location_list
    end

  end
end
