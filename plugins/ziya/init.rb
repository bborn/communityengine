XML_SWF = "plugin_assets/community_engine/charts/charts.swf?library_path=/charts/charts_library&xml_source=%s"

require File.dirname(__FILE__) + '/lib/ziya'    
require File.dirname(__FILE__) + '/lib/ziya_helper'    
require File.dirname(__FILE__) + '/lib/ziya_charting'    

ActionView::Base.send(:include, Ziya::Helper)       