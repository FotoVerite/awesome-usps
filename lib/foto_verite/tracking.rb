module FotoVerite
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
      xm = Builder::XmlMarkup.new
      xm.TrackFieldRequest("USERID" =>"#{@username}") do
        xm.TrackID("ID"=> "#{tracking_number}")
      end
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse_tracking(xml)
      event_list = []
      parse = Hpricot.parse(xml)/:trackdetail
      if parse == []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        parse.each do |detail|
          h = {}
          detail.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank? }
          event_list << h
        end
      end
      event_list
    end

  end
end
