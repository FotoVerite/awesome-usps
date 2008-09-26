module  FotoVerite
  module OpenDistrubutePriority

    def open_distrubute_priority_label(origin, destination, package_weight_in_ounces,  mail_type, image_type, label_type=1, api_requst = "OpenDistributePriorityRequest", options={})
      request = open_distrubute_priority_xml(api_requst, origin, destination, package_weight_in_ounces,  mail_type, image_type, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:open_distrubute_priority, 'OpenDistributePriority', request, :ssl, image_type)
    end

    def canned_open_distrubute_priority_label_test
      origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      destination =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",  :state => 'VA', :city => 'Fairfax', :zip5 => "22030", :facility_type => "DDU")
      mail_type = "Letters"
      image_type = "PDF"
      package_weight_in_ounces = 1
      options = {:address_service => true, :permit_number => "21718", :permit_zip => "07204"}
      api_requst = "OpenDistributePriorityCertifyRequest"
      label_type=1
      request= open_distrubute_priority_xml(api_requst, origin, destination, package_weight_in_ounces,  mail_type, image_type, label_type, options)
      gateway_commit(:open_distribute_priority_certify, 'OpenDistributePriorityCertify', request, :ssl, image_type)
    end

    private
    def open_distrubute_priority_xml(api_requst, origin, destination, package_weight_in_ounces,  mail_type, image_type, label_type, options)
      xm = Builder::XmlMarkup.new
      xm.tag!("#{api_requst}", "USERID"=>"#{@username}") do
        xm.PermitNumber(options[:permit_number])
        xm.PermitIssuingPOZip5(options[:permit_zip])
        xm.FromName(origin.name)
        xm.FromFirm(origin.firm_name)
        xm.FromAddress1(origin.address1) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.FromAddress2(origin.address2)
        xm.FromCity(origin.city)
        xm.FromState(origin.state)
        xm.FromZip5(origin.zip5)
        xm.FromZip4(origin.zip4)
        xm.POZipCode(options[:po_zip_code])
        xm.ToFacilityName(destination.name)
        xm.ToFacilityAddress1(destination.address1)
        xm.ToFacilityAddress2(destination.address2)
        xm.ToFacilityCity(destination.city)
        xm.ToFacilityState(destination.state)
        xm.ToFacilityZip5(destination.zip5)
        xm.ToFacilityZip4(destination.zip4)
        xm.FacilityType(destination.facility_type)
        xm.MailClassEnclosed(mail_type)
        xm.MailClassOther(options[:other])
        xm.WeightInPounds("0")
        xm.WeightInOunces(package_weight_in_ounces)
        xm.ImageType(image_type)
        xm.SeparateReceiptPage(options[:seperate])
        xm.LabelDate(options[:label_date])
        xm.AllowNonCleansedFacilityAddr("false")
      end
    end

    def parse_open_distrubute_priority(xml, image_type)
      if image_type == "TIF"
        image_type = "image/tif"
      else
        image_type = "application/pdf"
      end
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        number = Hpricot.parse(xml)/:opendistributeprioritynumber
        label = Hpricot.parse(xml)/:opendistributeprioritylabel
        return {:image_type => image_type, :number => number.inner_html, :label => label.inner_html}
      end
    end

  end
end
