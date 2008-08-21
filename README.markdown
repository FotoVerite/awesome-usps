# Awesome USPS

This library is meant to interface with the web services of USPS. It grew out of early dabbling of the USPS_Tracker plugin. The goal is to abstract the features that are most frequently used into a pleasant and consistent Ruby API. Awesome USPS started as an extension of Active Shipping but at the moment I am still struggling with how best to accomplish integration. While working on the problem I decided to release my current work as a separate plugin for all to enjoy. Next up the Awesome USPS gem.

[Matthew Bergman]:http://matthewbergman.com
[discuss]:http://groups.google.com/group/Awsome-USPS
[Active Shipping]:http://github.com/Shopify/active_shipping/tree/master



## Prerequisites

* [Hrpicot](http://code.whytheluckystiff.net/hpricot/) for parsing the XML. To install run sudo gem install Hpricot
* [mocha](http://mocha.rubyforge.org/) for the tests

## Download & Installation

Currently this library is available on GitHub:

  <http://github.com/FotoVerite/awesome_usps>

You will need to get [Git][] if you don't have it. Then:

  > script/plugin install  git://github.com/FotoVerite/awesome_usps.git

 if using rails prior to 2.1:

  > git clone git://github.com/FotoVerite/awesome_usps.git

(That URL is case-sensitive, so watch out.)
  
Awesome USPS includes an init.rb file. This means that Rails will automatically load it on startup. Check out [git-archive][] for exporting the file tree from your repository to your vendor directory.

Gem and tarball forthcoming on rubyforge.
  
[Git]:http://git.or.cz/
[git-archive]:http://www.kernel.org/pub/software/scm/git/docs/git-archive.html

## Notice about using the USPS APIs
 USPS can be a bit frustrating when starting working with them. First you must apply for a USPS web tools account
[USPS Web Tools]:https://secure.shippingapis.com/registration/

This will net you a USPS user name assigned by them and a password. The password is for older versions of their api so you do not need to concern yourself with it. 

Secondly you only have accesses to the Testing Server. You should run one of the canned response to make sure everything is setup up correctly. 
	
	usps.canned_tracking

You should receive an array as a response. 

From there you need to email USPS for your account to be changed over to production so you can send live data. This does not hold true for all their Api some of which require and additional level of clearance. See Below

## Notice on USPS Label APIs

 USPS is kinda... bad with how they handle their various label creation APIs. Except for their Priority Mail® Open and Distribute API you must make an additional email or call to their customer care center to have your permission turned on to send live data to the server. It is even more complicated if you wish to create your own labels with your company logo from their response xml. See their API documentation located at
[http://www.http://www.usps.com/webtools/htm/Delivery-Confirmation.htm]:http://www.usps.com/webtools/htm/Delivery-Confirmation.htm for details on the procedure.

## Notice on Address Information APIs
These APIs; Specifically Address Verify, Zip Lookup, and City State Lookup also need separate permission for use of live data. 

## Canned Tests
Because most of the API's require an additional level of permission to use with live data every method has a canned test. They are both useful for integrating the returned data with your system and for testing that the library has not been compromised. A canned method follow this format. canned\_method\_name\_test. 
 
## Awesome USPS methods

API methods are as follow

* track
* veryify_address
* zip_lookup
* city\_state\_lookup
* delivery\_confirmation\_label
* signature\_confirmation\_label
* merch_return
* express_mail
* express\_mail\_international\_label
* priority\_mail\_international\_label
* first\_class\_international\_label
* open\_distrubute\_priority\_label
* priority\_mail\_estimated\_time
* standard\_mail\_estimated\_time
* domestic_rates
* world_rates

Object Methods are as follow

* Package.new
* Location.new
* International Location #Only used in conjunction with international labels API

# Sample Usage
	#In your environment.rb or production.rb
    include FotoVerite

	# Then to access the plugin you much create an instance of USPS class
	 usps = USPS.new('Your user name')
	
  
    # Package up a poster and a Wii for your nephew.
	# Note the Package Module has been taken directly from Active Shipping. Thank you James MacAulay for developing such great code. 
    packages = [
      Package.new(  100,                        # 100 grams
                    [93,10],                    # 93 cm long, 10 cm diameter
                    :cylinder => true),         # cylinders have different volume calculations
    
      Package.new(  (7.5 * 16),                 # 7.5 lbs, times 16 oz/lb.
                    [15, 10, 4.5],              # 15x10x4.5 inches
                    :units => :imperial)        # not grams, not centimetres
    ]
	
	#Create a location to use with the Api
	 sender =Location.new(:name => "Matthew Bergman ",:first_name => "Matthew", :last_name => "Bergman",
	:address1 => Apt 4m, :address2 => "1001 Pine Street", 
	:city => "New York", :state => "NY", :zip5 => "100010", :phone => "5555555555")
	
	#International Item Class
	#Only should be used in conjunction with the Internal Label Api 
	Items = [
		InternationalItem.new( 
		:description => Pens", 
		:quantity => "50" 
		:value => 200.40,     					#Will be converted back to a float if entered as a string. 
	    :ounces => "50",							
	    :tariff_number => "Only use if known"	#Optional input for the api. 
	    :country => "United States")
	
		InternationalItem.new( 
		:description => "Against The Day, Pynchon",
	    :quantity => "10"
	    :value => 100.25
	    :ounces => "250"
	    :country => "United States")
	]
	
### Note for working with Location Class
		#The api is very quirky about how it handles addresses. :address1 is for inputing Apt or Suite numbers and nothing else. 
		#Besides the obvious info, it can contain, :facility_type and :from_urbanization, which are used for specific Apis.
  
##To track a package

	USPS.track("Tracking Number")
	
	#This will return an array of tracking events example shown below
	
	[{:eventzipcode=>"33436", :event=>"Arrival at Unit", :eventtime=>"7:23 am", :eventdate=>"June 14, 2008",
	 :eventcity=>"BOYNTON BEACH", :eventstate=>"FL"},
	 {:eventzipcode=>"32862", :event=>"Processed", :eventtime=>"9:50 pm", 
	 :eventdate=>"June 13, 2008", :eventcity=>"ORLANDO", 	:eventstate=>"FL"},
	 {:eventzipcode=>"07032", :event=>"Processed", :eventtime=>"1:19 am",
	 :eventdate=>"June 13, 2008", :eventcity=>"KEARNY", 	:eventstate=>"NJ"},
	 {:eventzipcode=>"07024", :event=>"Acceptance", :eventtime=>"3:03 pm", :eventdate=>"June 12, 
	 2008", :eventcity=>"FORT LEE", :eventstate=>"NJ"}]
	
	#Loop through and display as you wish
	
##To get rates for a single or group of packages. 
	
 	#There are two APIs. One for domestic, the other for international packages. 

	USPS.domestic_rates(ZIP, Packages, options={})
	USPS.world_rates(Country, Packages, options={})
	
	#Both will return and array containg a hash of rates for each package.
	
	#To access a rate hash for use you can do 
	
	array = USPS.world_rates(Country, Packages, options={})
	array[0][Priority Mail International]
	
	#You can also loop through and sort

##Address Verification

	#All methods here will take a location array of up to five address
	
	#To verify an address and fill in missing information. If mulitple addresses were found for an address :verified => false
    usps.veryify_address("locations array")
	
	#Will fill in missing zip5 and zip4 for an address
	usps.zipcode_lookup("location array")
	
	#Will fill in missing City and State for an address
	usps.city_state_lookup
	
##Service Standards

	usps.priority_mail_estimated_time(origin, destination)
	usps.standard_mail_estimated_time(origin, destination)
	
	#Both of these methods returns a number for the amount of days a package will take to reach 
	#its destination. 
## Express Mail Commitment

	usps.express_mail_commitment(origin, destination, date=nil)
	
	#returns a array of hashs containing commitment information. Example shown below
	
	[{:state=>"MD", :cutoff=>"6:00 PM", :facility=>"EXPRESS MAIL COLLECTION BOX", :zip=>"20770", 
	:street=>"119 CENTER WAY", :city=>"GREENBELT"}, {:state=>"MD", :cutoff=>"3:00 PM", 
	:facility=>"EXPRESS MAIL COLLECTION BOX", :zip=>"20770", :street=>"7500 GREENWAY CENTER DRIVE", 
	:city=>"GREENBELT"}]	

#Label APIs
	#All label API's generate a label image  encoded via 64bit encryption. It must be decrypted by using  
	#Base64.decode64(Image_file) to display correctly. The only choices for image_type right now are pdf and TIFF
	
	#An easy way to test and intergrate is to set up something along these lines in a controller. 
	
	def deliver_confirmation
    	image = USPS.new("XXXXXX").canned\_delivery\_confirmation\_label_test
    	send_data Base64.decode64(image[:label]), :type => image[:image_type], :disposition => "inline"
  	end
	
	#All labels except for international labels take a straight name for their XML. 
	#When using International label APIs you must include both a first and last name
 

## Delivery and Signature Label Creation
	usps.delivery_confirmation_label(origin, destination, service_type, image_type, label_type=1, options={})
	usps.signature_confirmation_label(origin, destination, service_type, image_type, label_type=1, options={}) 
	
	#label_type can be set to 2 if you desire to create your own labels. No label will be generated for you,
	#you simply will receive a 	confirmation label to use with the image you create. 
	
	#Option hash can contain
	
	* :weight_in_ounces 
	* :seperate => puts the label directions on a seperate page. 
	* :po_zip_code => Post Offic zip code
	* :label_date => Can be set up to four days in the future
	* :customer_reference_number
	* :address_service => ill be notified in the future if address has been changed
	* :sender_name, :sender_email, 
	  :recipient_name, :recipient_email  => Used together to send an email to the recipient. 
	 
## Electronic Merchandise Return Label Creation
	usps.merch_return(service_type, customer, retailer, permit_number, 
					  post_office, postage_delivery_unit,  ounces, image_type, options={})
					
	#permit_number => Input permit number provided by your local post office.
	#post_office => Location class of post office that issued the permit. Address not needed
	#postage_delivery_unit => Location class for delivery unit you are sending the package to.
	
	#Option hash can contain
	
	 * :confirmation => "Includes delivery confirmation with the label. To enable set to true" 
	 * :insurance_value 
	 * :rma => "Return Materials Authorization Number"
	 * :RMABarcode => "Will Render Barcode on Label if set to true and a RMA has been entered"
	 * :sender_name, :sender_email, 
	   :recipient_name, :recipient_email  => Used together to send an email to the recipient. 
	
	#Output hash contains postnet number and the cost for sending. Under :postnet and :cost respectively. 

## Express Mail Label Creation
	usps.express_mail_label(orgin, destination, ounces, image_type, options={})
	
	#Option hash can contain
	
	 * :flat_rate => "Can be set to true if using flat rate envelopes"
	 * :standardize_address => "Verify Address"
	 * :waiver_signature => "No Signature Required for Delivery"
	 * :no_holiday => "Do not deliver on a holiday"
	 * :no_weekend
	 * :seperate => puts the label directions on a seperate page
	 * :po_zip_code
	 * :label_date  => Can be set up to four days in the future
	 * :sender_name, :sender_email, 
	   :recipient_name, :recipient_email  => Used together to send an email to the recipient. 
	
	#Output hash contains postage cost for sending. Can be accessed by :postage
	
## International Mail Labels Creation
	usps.express_mail_international_label(sender, receiver, items, image_type, po_box_flag ="N",
  	image_layout="ALLINONEFILE", label_type="1", options={})

	usps.priority_mail_international_label(sender, receiver, items, image_type, po_box_flag ="N",
  	image_layout="ALLINONEFILE", label_type="1", options={})

	usps.first_class_international_label(sender, receiver, items, image_type, po_box_flag ="N",
  	image_layout="ALLINONEFILE", label_type="1", options={})
	
	#label_type can be set to 2 if you desire to create your own labels. No label will be generated for you,
	#items => InternationalItem.new can be an array of objects or singular
	#content_type => Options are "MERCHANDISE", "SAMPLE", "GIFT", "DOCUMENTS", "RETURN", "OTHER"
	#If OTHER is selected content type must be described by :other => "Description" in the option hash.
	#image_layout => "Allows for a few options"
	#po_box_flag  can be set to "Y" if items are being sent to a PO-Box
	
	Option Hash for priority and express can contain
	
	 * :middle_initial => "middle initial of sender"
	 * :from_customs_reference
	 * :to_customs_reference
	 * :fax => "fax of receiver"
	 * :email => "email of receiver"
	 * :non_delivery_option => "Return, Reject, Abaddon. Defaults to abaddon."
	 * :alt_return_address1 => "used to explain where package goes 
		if delivery_option set to . Goes up to alt_return_address6"
	 * :alt_return_country
	 * :container => "VARIABLE or FLATRATEENV"
	 * :insurance_number
	 * :Postage => "If postage is already known. Will be caculated if left blank. "
	 * :other
	 * :comments
	 * :license_number
	 * :certificate_number
	 * :invoice_number
	 * :reference_number
	 * :po_zip_code
	 * :label_date  => Can be set up to four days in the future
	 * :hold => "Hold for manifest"
	
	Option Hash for first_class can contain
	
	 * :middle_initial => "middle initial of sender"
	 * :from_customs_reference
	 * :to_customs_reference
	 * :fax => "fax of receiver"
	 * :email => "email of receiver"
	 * :first_class_mail_type
	 * :machinable => "True or False"
	 * :other
	 * :comments
	 * :label_date  => Can be set up to four days in the future
	 * :hold => "Hold for manifest"
	
	#Output hash contains postage cost, total value of all items, SDRValue and the Bar code number.
	#Can be access :postage, :totalvalue, :sdrvalue, and :barcodenumber respectively. 
	
	<Postage>96.25</Postage>
	            <TotalValue>16.65</TotalValue>
	            <SDRValue>11.42</SDRValue>
	            <BarcodeNumber>LJ000100644US</BarcodeNumber>
## Open Distribute Priority Label Creation
	#TODO a good description for what Open Distribute Priority actually means
	
	usps.open_distrubute_priority_label(orgin, destination, 
		 package_weight_in_ounces, mail_type, image_type, label_type=1, options={})
		
	#label_type can be set to 2 if you desire to create your own labels. No label will be generated for you,
	#you simply will receive a 	confirmation label to use with the image you create.
	
	#destination class must contain :facility_type, See API Document for explination of the different types
	
	#mail_type can be be, "Letters", "Flats", "Parcels", "Mixed" or "Other" 
	#If other is chosen it must be described in the option hash via :other => "Description"

	#Option has can contain
	
	 * :permit_number => "Issued by Post Office"
	 * :permit_zip => "Zip of Post Office that issued permit. Must be included if using :permit_number"
	 * :po_zip_code
	 * :other
	 * :no_weekend
	 * :seperate => puts the label directions on a seperate page
	 * :label_date  => Can be set up to four days in the future
		
## TODO

* Proofread documentation
* package into a gem
* Add tests with RSPEC

## Contributing

Yes, please! I am a young Ruby Developer who is making plenty mistakes. Any improvements to the coding structure or patches would be highly appreciated. 

The nicest way to submit changes would be to set up a GitHub account and fork this project, then initiate a pull request when you want your changes looked at. You can also make a patch (preferably with [git-diff][]) and email to FotoVerite@gmail.com

[git-diff]:http://www.kernel.org/pub/software/scm/git/docs/git-diff.html



## Legal Mumbo Jumbo

Unless otherwise noted in specific files, all code in the Awesome USPS is under the copyright and license described in the included MIT-LICENSE file.

Packages Module created by James MacAulay

Copyright (c) 2008 Matthew Bergman, released under the MIT license
