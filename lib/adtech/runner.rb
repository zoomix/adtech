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
      @config_destination_dir = "/tmp/adtech"
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
    
    def get_campaigns
      aove = AttributeOperatorValueExpression.new
      aove.setAttribute("statusTypeId")
      aove.setOperator(IAttributeOperatorValueExpression.OP_EQUAL)
      aove.setValue(ICampaign.STATUS_ACTIVE)
      
      filter = java.util.Vector.new
      filter.add(aove)

      boolExpression = BoolExpression.new
      boolExpression.setExpressions(aove)
      
      list = cs.getCampaignList(nil, nil, boolExpression, nil)
    end
  end
end
