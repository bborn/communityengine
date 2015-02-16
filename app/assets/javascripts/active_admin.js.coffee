#= require active_admin/base
#= require jquery.turbolinks
#= require turbolinks
#= require ckeditor/init
#= require_directory ./ckeditor/rte


$(document).on 'page:receive', ->
  for name in CKEDITOR.instances
    CKEDITOR.instances[name].destroy()
