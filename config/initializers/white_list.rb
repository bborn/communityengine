WhiteListHelper.settings[:attributes]['object'] = %w[classid codebase width height align id salign flashvars]
WhiteListHelper.settings[:attributes]['param']  = %w[name value type]
WhiteListHelper.settings[:attributes]['embed']  = %w[src quality salign scale bgcolor align menu pluginspage type width height wmode flashvars]
WhiteListHelper.settings[:attributes]['iframe'] = %w[src frameborder width height]