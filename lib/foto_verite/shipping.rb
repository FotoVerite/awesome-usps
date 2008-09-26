module FotoVerite
  module Shipping

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    API_CODES = {
      :us_rates => 'RateV3',
      :world_rates => 'IntlRate',
    }

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

    def canned_domestic_rates_test
      origin_zip = "07024"
      packages =[
        Package.new(  100,
        [93,10],
        :cylinder => true),

        Package.new(  (7.5 * 16),
        [15, 10, 4.5],
        :units => :imperial)
      ]
      destination_zip = "10010"
      options = {}
      request = xml_for_us(origin_zip, destination_zip, packages, options)
      gateway_commit(:us_rates, 'RateV3', request, :live)
    end


    def canned_world_rates_test
      api_request='IntlRate'
      packages =  [
        Package.new(  100,
        [93,10],
        :cylinder => true),

        Package.new(  (7.5 * 16),
        [15, 10, 4.5],
        :units => :imperial)
      ]
      country = "Japan"
      options ={}
      request = xml_for_world(country, packages, options)
      gateway_commit(:world_rates,'IntlRate', request, :live)
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
      xm = Builder::XmlMarkup.new
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

    # XML built with Build:XmlMarkup
    def xml_for_world(country, packages, options)
      xm = Builder::XmlMarkup.new
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


    # Returns the sent xml as a hash orgainzied by each package and service type.
    # example
    # {Package1 =>{'First Class' => "1.90"}Package2 => {'First Class' => "26.90" }

    def parse_us(xml)
      i=0
      domestic_rate_array = []
      Hpricot.parse(xml).search('package').each do |package|
        h = {}
        i+=1
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        if package.search("error") != []
          RAILS_DEFAULT_LOGGER.info("package number #{i} has the error #{package.search("description").inner_html} please fix before continuing")

          return "package number #{i} has the error #{package.search("description").inner_html} please fix before continuing"
        end
        #Going through each package and finding the rate.
        package.search("postage").each do |services|

          mailservice=services.search("mailservice")
          rate = services.search("rate")
          h[mailservice.inner_html] = rate.inner_html
        end
        domestic_rate_array << h
      end
      if  domestic_rate_array == []
        return Hpricot.parse(xml).search('description').inner_html
      end
      return domestic_rate_array
    end

    def parse_world(xml)
      international_rate_array = []
      i= 0
      Hpricot.parse(xml).search('package').each do |package|
        i+=1
        h = {}
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        if package.search("error") != []
          RAILS_DEFAULT_LOGGER.info("package number #{i} has the error #{package.search("description").inner_html} please fix before continuing")

          return "package number #{i} has the error #{package.search("description").inner_html} please fix before continuing"
        end
        #Going through each package and finding the rate.
        package.search("service").each do |services|

          svcdescription=services.search("svcdescription")
          rate = services.search("postage")
          h[svcdescription.inner_html] = rate.inner_html

        end
        international_rate_array << h
      end
      if   international_rate_array == []
        return Hpricot.parse(xml).search('description').inner_html
      end
      return international_rate_array
    end

  end
end
