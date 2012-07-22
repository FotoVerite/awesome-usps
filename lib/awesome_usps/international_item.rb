module AwesomeUsps #:nodoc:
  class InternationalItem

    attr_reader :options,
    :description,
    :quantity,
    :value,
    :pounds,
    :ounces,
    :tariff_number,
    :country

    alias_method :from_country, :country
    alias_method :country_of_origin, :from_country

    def initialize(options = {})
      @description = options[:description]
      @quantity= options[:quantity]
      @value = options[:value]
      @pounds = options[:pounds]
      @ounces = options[:ounces]
      @tariff_number = options[:tariff_number]
      @country = options[:country]
    end

    def to_s
      prettyprint.gsub(/\n/, ' ')
    end

    def prettyprint
      chunks = []
      chunks << [@description,@quantity,@value, @tariff_number, @country].reject {|e| e.blank?}.join("\n")
      chunks << [@pounds,@ounces].reject {|e| e.blank?}.join(', ')
      chunks.reject {|e| e.blank?}.join("\n")
    end

    def inspect
      string = prettyprint
      string
    end
  end

end
