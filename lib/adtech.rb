# encoding: utf-8

require 'java'
java_import java.lang.System
System.setProperty("http.nonProxyHosts", "")
$CLASSPATH << "lib/ext/HeliosWSClientSystem_1.10.1"
$CLASSPATH << "lib/ext/HeliosWSClientSystem_1.10.1/lib"
require 'ext/HeliosWSClientSystem_1.10.1/HeliosWSClientSystem'

require 'adtech/banner'
require 'adtech/campaign'
require 'adtech/campaign_report'
require 'adtech/runner'
