module AwesomeUsps
  module Shipping

    CONTAINERS = {
      :envelope => 'Flat Rate Envelope',
      :box => 'Flat Rate Box'
    }
    MAIL_TYPES = {
      :package => 'Package',
      :postcard => 'Postcards or aerogrammes',
      :matter_for_the_blind => 'Matter for the blind',
      :envelope => 'Envelope'
    }
    PACKAGE_PROPERTIES = {
      'ZipOrigination' => :origin_zip,
      'ZipDestination' => :destination_zip,
      'Pounds' => :pounds,
      'Ounces' => :ounces,
      'Container' => :container,
      'Size' => :size,
      'Machinable' => :machinable,
      'Zone' => :zone,
      'Postage' => :postage,
      'Restrictions' => :restrictions
    }
    POSTAGE_PROPERTIES = {
      'MailService' => :service,
      'Rate' => :rate
    }
    US_SERVICES = {
      :first_class => 'FIRST CLASS',
      :priority => 'PRIORITY',
      :express => 'EXPRESS',
      :bpm => 'BPM',
      :parcel => 'PARCEL',
      :media => 'MEDIA',
      :library => 'LIBRARY',
      :all => 'ALL'
    }


    # options Are?
    def domestic_rates(origin_zip, destination_zip, packages, options={})
      Array(packages)  if not packages.is_a? Array
      request = xml_for_us(origin_zip, destination_zip, packages, options)
      gateway_commit(:us_rates, 'RateV3', request, :live)
    end

    # options Are?
    def world_rates(country, packages, api_request='IntlRate', options={})
      Array(packages)  if not packages.is_a? Array
      request = xml_for_world(country, packages, options)
      gateway_commit(:world_rates, 'IntlRate', request, :live)
    end


    private

    #Determins size of package automatically. Taken from Active_Shipping
    def size_code_for(package)
      total = package.inches(:length) + package.inches(:girth)
      if total <= 84
        return 'REGULAR'
      elsif total <= 108
        return 'LARGE'
      else # <= 130
        return 'OVERSIZE'
      end
    end

    # XML built with Build:XmlMarkup
    def xml_for_us(origin_zip, destination_zip, packages, options)
      builder = Nokogiri::XML::Builder.new do |xm|
        xm.RateV3Request("USERID"=>"#{@username}") do
          packages.each_index do |id|
            p = packages[id]
            xm.Package("ID" => "#{id}") {
              xm.Service("#{US_SERVICES[options[:service]] || :all}")
              xm.ZipOrigination(origin_zip)
              xm.ZipDestination(destination_zip)
              xm.Pounds("0")
              xm.Ounces("#{'%0.1f' % [p.ounces,1].max}")
              if p.options[:container] and [nil,:all,:express,:priority].include? p.service
                xm.Container(CONTAINERS[p.options[:container]])
              end
              xm.Size(size_code_for(p))
              xm.Width(p.inches(:width))
              xm.Length(p.inches(:length))
              xm.Height(p.inches(:height))
              xm.Girth(p.inches(:girth))
              xm.Machinable((p.options[:machinable] ? true : false).to_s.upcase)
            }
          end
        end
      end
      builder.doc.root.to_xml
    end

    # XML built with Build:XmlMarkup
    def xml_for_world(country, packages, options)
        builder = Nokogiri::XML::Builder.new do |xm|
         xm.IntlRateRequest("USERID"=>"#{@username}") do
          packages.each_index do |id|
            p = packages[id]
            xm.Package("ID" => "#{id}") {
              xm.Pounds("0")
              xm.Ounces("#{'%0.1f' % [p.ounces,1].max.ceil}")
              xm.MailType("#{MAIL_TYPES[p.options[:mail_type]] || 'Package'}")
              xm.ValueOfContents(p.value / 100.0) if p.value && p.currency == 'USD'
              xm.Country(country)
            }
          end
        end
      end
      builder.doc.root.to_xml
    end


    # Returns the sent xml as a hash orgainzied by each package and service type.
    # example
    # {Package1 =>{'First Class' => "1.90"}Package2 => {'First Class' => "26.90" }

    def parse_us(xml)
      doc = Nokogiri::XML(xml)
      domestic_rate_array = []
      doc.search('Package').each_with_index do |package, i|
        h = {}
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        raise(USPSResponseError, "package number #{i} has the error #{package.search("Description").inner_html} please fix before continuing")unless doc.xpath("Error").empty?
        #Going through each package and finding the rate.
        package.search("Postage").each do |services|

          mailservice=services.search("MailService")
          rate = services.search("Rate")
          h[mailservice.inner_html] = rate.inner_html
        end
        domestic_rate_array << h
      end
      return domestic_rate_array
    end

    def parse_world(xml)
      doc = Nokogiri::XML(xml)
      international_rate_array = []
      doc.search('Package').each_with_index do |package, i|
        h = {}
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        raise(USPSResponseError, "package number #{i} has the error #{package.search("Description").inner_html} please fix before continuing")unless doc.xpath("Error").empty?

        #Going through each package and finding the rate.
        package.search("Service").each do |services|

          svcdescription=services.search("SvcDescription")
          rate = services.search("Postage")
          h[svcdescription.inner_html] = rate.inner_html

        end
        international_rate_array << h
      end
      return international_rate_array
    end

  end
end
