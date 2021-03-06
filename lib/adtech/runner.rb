# encoding: utf-8

# This runner will take a config file, copy it to a temporary directory along with 
# all the other config files needed in the base config dir

require 'tmpdir'
java_package 'de.adtech.helios'
java_import 'java.security.NoSuchProviderException'
java_import 'org.systinet.wasp.webservice.LookupException'
java_import 'de.adtech.webservices.helios.client.HeliosWSClientSystem'
java_import 'de.adtech.helios.AttributeOperatorValueExpression'
java_import 'de.adtech.webservices.helios.lowLevel.constants.IAttributeOperatorValueExpression'
java_import 'de.adtech.webservices.helios.lowLevel.constants.ICampaign'
java_import 'de.adtech.helios.BoolExpression'

module Adtech
  class Runner
    SERVER_URL = "https://ws.adtech.de".freeze
    WSDL_URL = "http://ws.adtech.de".freeze

    attr_reader :helios

    def initialize(path_to_config_file, username, password)
      @config_destination_dir = Dir.tmpdir
      base_conf_dir = File.expand_path('../../ext/HeliosWSClientSystem_1.10.1/conf', __FILE__)
      FileUtils.cp_r(base_conf_dir, @config_destination_dir)
      FileUtils.cp(path_to_config_file, File.join(@config_destination_dir, 'conf', 'clientconf.xml'))
      @username = username
      @password = password
      @cache = Hash.new {|h, k| h[k] = {}}
      startup
    end
    
    def startup
      @helios = HeliosWSClientSystem.new
      @helios.init_services(SERVER_URL, WSDL_URL, @config_destination_dir, @username, @password)
    end
    
    def get_campaigns(limit = nil)
      aove = AttributeOperatorValueExpression.new
      aove.setAttribute("statusTypeId")
      aove.setOperator(IAttributeOperatorValueExpression.OP_EQUAL)
      aove.setValue(ICampaign.STATUS_ACTIVE)
      
      filter = java.util.Vector.new
      filter.add(aove)

      boolExpression = BoolExpression.new
      boolExpression.setExpressions(filter)
      
      puts "Fetching campaigns, will probably take a while..."
      list = @helios.campaignService.getCampaignList(0.to_java, limit.to_java, boolExpression, nil)
      puts "Received #{list.length} campaigns"
      index = 0
      list.map do |item|
        Campaign.new(item, get_advertiser(item.advertiserId), get_customer(item.customerId))
      end
    end


    def get_campaign_reports(limit = nil)
      aove = AttributeOperatorValueExpression.new
      aove.setAttribute("statusTypeId")
      aove.setOperator(IAttributeOperatorValueExpression.OP_EQUAL)
      aove.setValue(ICampaign.STATUS_ACTIVE)
      
      filter = java.util.Vector.new
      filter.add(aove)

      boolExpression = BoolExpression.new
      boolExpression.setExpressions(filter)
      
      puts "Fetching campaigns, will probably take a while..."
      campaigns = @helios.campaignService.getCampaignList(0.to_java, limit.to_java, boolExpression, nil)
      puts "Received #{campaigns.length} campaigns. Getting statistics"
      campaigns.reduce([]) do |campaign_reports, raw_campaign|
        raw_report = @helios.statisticsService.get_campaign_statistics_by_campaign_id(raw_campaign.get_id)
        campaign_reports << CampaignReport.new(raw_report, raw_campaign, get_advertiser(raw_campaign.advertiserId), get_customer(raw_campaign.customerId)) if raw_report
        campaign_reports
      end
    end
    
    def get_advertiser(id)
      @cache[:advertiser][id] ||= begin
        @helios.customerService.getAdvertiserById(id, nil)
      end
    end
    
    def get_customer(id)
      @cache[:customer][id] ||= begin
        @helios.customerService.getCustomerById(id, nil)
      end
    end
  end
end
