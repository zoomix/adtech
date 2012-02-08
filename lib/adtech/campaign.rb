module Adtech
  class Campaign
    FIELDS = [:name, :advertiser, :customer, :campaign_id, :cpm, :cpc, :flatfee, :target]
    attr_reader *FIELDS
    attr_reader :banners, :start_date, :end_date
    
    def initialize(init, advertiser = nil, customer = nil)
      if init.is_a?(Hash)
        from_hash(init)
      else
        from_api(init, advertiser, customer)
      end
    end
    
    def to_h
      ret = {}
      FIELDS.each do |v|
        ret[v.to_s] = instance_variable_get("@#{v}")
      end
      [:start_date, :end_date].each do |v|
        ret[v.to_s] = instance_variable_get("@#{v}").to_i
      end
      ret['banners'] = @banners.map {|b| b.to_h }
      ret
    end
    
    private
    def from_api(api_campaign, advertiser, customer)
      @name = api_campaign.name
      @campaign_id = api_campaign.getId
      @cpm = api_campaign.pricingConfig.cpm
      @cpc = api_campaign.pricingConfig.cpc
      @flatfee = api_campaign.pricingConfig.flatfee
      @target = api_campaign.pricingConfig.target
      @start_date = Time.at(api_campaign.absoluteStartDate.getTime/1000)
      @end_date = Time.at(api_campaign.absoluteEndDate.getTime/1000)
      @advertiser = advertiser.name if advertiser
      @customer = customer.name if customer
      @banners = []
      api_campaign.getBannerTimeRangeList.each do |timerange|
        timerange.getBannerInfoList.each do |banner|
          @banners << Banner.new(banner)
        end
      end
    end
    
    def from_hash(hash)
      FIELDS.each do |v|
        instance_variable_set("@#{v}", hash[v.to_s])
      end
      [:start_date, :end_date].each do |v|
        instance_variable_set("@#{v}", Time.at(hash[v.to_s]))
      end
      @banners = []
      hash['banners'].each do |b|
        @banners << Banner.new(b)
      end
    end
  end
end