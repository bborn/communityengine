require 'apis/meta_weblog_service'

class XmlrpcController < BaseController
  session :off
  web_service_dispatching_mode :layered

  web_service :metaWeblog, MetaWeblogService.new
  web_service :blogger, MetaWeblogService.new
end
