module Adtech
  class Banner
    attr_reader :number, :name
   
    def initialize(init)
      if init.is_a?(Hash)
        from_hash(init)
      else
        from_api(init)
      end
    end
    
    def to_h
      {
        'name' => @name,
        'number' => @number
      }
    end
    
    private
    def from_api(api_banner)
      @number = api_banner.getBannerNumber
      @name = api_banner.name
    end
    
    def from_hash(hash)
      @number = hash['number']
      @name = hash['name']
    end
  end
end