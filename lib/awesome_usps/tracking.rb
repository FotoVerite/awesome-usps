module AwesomeUsps
  module Tracking
    
    # Takes your package tracking number and returns information for the USPS web API
    def track(tracking_number)
      request = xml_for_tracking(tracking_number)
      gateway_commit(:tracking, 'TrackV2', request, :live)
    end

    def canned_tracking
      tracking_number = "EJ958083578US"
      request = xml_for_tracking(tracking_number)
      gateway_commit(:tracking, 'TrackV2', request, :test)
    end

    # XML from a straight string.
    # "<TrackFieldRequest USERID='#{@username}'><TrackID ID='#{@tracking_number}'></TrackID></TrackFieldRequest>"
    def xml_for_tracking(tracking_number)
      builder = Nokogiri::XML::Builder.new do |xm|
        xm.TrackFieldRequest("USERID" =>"#{@username}") do
          xm.TrackID("ID"=> "#{tracking_number}")
        end
      end
      builder.doc.root.to_xml
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse_tracking(xml)
      doc = Nokogiri::XML(xml)
      event_list = []
      parse = doc.xpath('//TrackDetail')
      raise(USPSResponseError, doc.search('Description').inner_html) if parse.empty?
      parse.each do |detail|
        h = {}
        detail.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.empty? }
        event_list << h
      end
      event_list
    end

  end
end
