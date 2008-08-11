module ForteDesigns
  class USPS
    def initialize(username)
      @username = validate(username)
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
    include ForteDesigns::Tracking
    include ForteDesigns::Shipping
    
  end
end
