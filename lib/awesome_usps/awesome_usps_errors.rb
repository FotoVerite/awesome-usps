module AwesomeUsps

  class USPSResponseError < StandardError
    def initialize(msg = "XML is badly formed")
      super(msg)
    end
  end

   class USPSTimoutError < StandardError
    def initialize(msg = "The site is down")
      super(msg)
    end
  end

end