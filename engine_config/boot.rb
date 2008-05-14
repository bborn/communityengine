CommunityEngine.check_for_pending_migrations


ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:database_manager => SqlSessionStore)
SqlSessionStore.session_class = MysqlSession
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update :line_grapher => '%Y%m%dT%H:%M:%S'
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update :line_graph => '%m/%d'

Mime::Type.register "text/javascript", :widget
Mime::Type.register "text/javascript", :js
Mime::Type.register "application/pdf", :pdf
 
COMMUNITY_EXAMPLE_STYLES = {}
Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', 'files', 'styles', '*.{txt}')).collect{|filename| 
    COMMUNITY_EXAMPLE_STYLES[File.basename(filename, ".txt" ).to_sym] = File.open(filename).read
}
WhiteListHelper.attributes[nil] = %w(id class style align)
WhiteListHelper.attributes['u'] = %w(class)
WhiteListHelper.attributes['strike'] = %w(class)
WhiteListHelper.attributes['object'] = %w(classid codebase width height align id salign flashvars)
WhiteListHelper.attributes['param']  = %w(name value type)
WhiteListHelper.attributes['embed']  = %w(src quality salign scale bgcolor align menu pluginspage type width height wmode flashvars)
WhiteListHelper.attributes['iframe'] = %w(src frameborder width height)

AppConfig.default_mce_options = {
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
  :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => true,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => %w{bold italic underline separator justifyleft justifycenter justifyright indent outdent separator bullist numlist separator link unlink image media separator undo redo help code},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{media preview curblyadvimage inlinepopups safari},
  :plugin_preview_pageurl => '../../../../../posts/preview',
  :plugin_preview_width => "950",
  :plugin_preview_height => "650",
  :editor_deselector => "mceNoEditor",
  :extended_valid_elements => "img[class|src|flashvars|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|obj|param|embed|scale|wmode|salign|style],embed[src|quality|scale|salign|wmode|bgcolor|width|height|name|align|type|pluginspage|flashvars],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|style|tabindex|title|type|usemap|vspace|width]"  
  }
  
AppConfig.simple_mce_options = {
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
  :cleanup_on_startup => true,
  :convert_fonts_to_spans => true,
  :theme_advanced_resizing => true, 
  :theme_advanced_toolbar_location => "top",  
  :theme_advanced_statusbar_location => "bottom", 
  :editor_deselector => "mceNoEditor",
  :theme_advanced_resize_horizontal => false,  
  :theme_advanced_buttons1 => %w{bold italic underline separator bullist numlist separator link unlink image separator help},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{inlinepopups safari curblyadvimage}
  }