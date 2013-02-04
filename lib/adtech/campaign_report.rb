module Adtech
  class CampaignReport
    FIELDS = [:campaign_name, :advertiser, :customer, :campaign_id, :clicks, :impressions]
    attr_reader *FIELDS
    attr_reader :start_date, :end_date
    
    def initialize(raw_report, raw_campaign, advertiser = nil, customer = nil)
      from_api(raw_report, raw_campaign, advertiser, customer)
    end
    
    def to_h
      ret = {}
      FIELDS.each do |v|
        ret[v.to_s] = instance_variable_get("@#{v}")
      end
      [:start_date, :end_date].each do |v|
        ret[v.to_s] = instance_variable_get("@#{v}").to_i
      end
      ret
    end
    
    private
    def from_api(report, campaign, advertiser, customer)
      @clicks = report.overall_clicks
      @impressions = report.overall_imps
      @campaign_name = campaign.name
      @campaign_id = campaign.getId
      @start_date = Time.at(campaign.absoluteStartDate.getTime/1000)
      @end_date = Time.at(campaign.absoluteEndDate.getTime/1000)
      @advertiser = advertiser.name if advertiser
      @customer = customer.name if customer
    end
  end
end