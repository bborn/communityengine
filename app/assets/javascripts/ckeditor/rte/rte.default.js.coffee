$.rte_default = ->
  CKEDITOR.replaceAll (textarea, config) ->
    config.customConfig = window['CKEDITOR_BASEPATH'] + '/configs/default.js'
    if $(textarea).hasClass("rich_text_editor") and ( ($(textarea).attr("id") isnt "post_raw_post") and ($(textarea).attr("id") isnt "comment_comment") and ($(textarea).attr("id") isnt "ad_html"))
      true
    else
      false


$(document).ready ->
  $.rte_default()
