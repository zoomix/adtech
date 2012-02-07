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
      list.each do |item|
        c = Campaign.new(item)
        p c.to_h
        # data = []
        # data << index
        # data << item.name
        # data << item.campaign_type_id
        # data << item.getId
        # data << item.absoluteStartDate.toString
        # data << item.absoluteEndDate.toString
        # item.dateRangeList.each do |daterange|
        #   data << "/"
        #   data << daterange.deliveryGoal.views
        #   data << daterange.deliveryGoal.clicks
        # end
        # data << ":"
        # data << item.pricingConfig.invoiceImpressions
        # data << item.pricingConfig.cpm
        # data << item.pricingConfig.cpc
        # data << item.pricingConfig.flatfee
        # data << item.pricingConfig.target
        # data << item.pricingConfig.clickrate
        # data << ":"
        # data << item.customerPricingConfigs.length
        # if item.customerPricingConfigs.length > 0
        #   item.customerPricingConfigs.each do |price|
        #     data << price.getPrice
        #   end
        # end
        # p data
        # index += 1
      end
    end
  end
end
