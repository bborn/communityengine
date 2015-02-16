$.rte_posts = ->
  CKEDITOR.replaceAll (textarea, config) ->
    config.customConfig = window['CKEDITOR_BASEPATH'] + '/postsconfig.js'
    if $(textarea).hasClass("rich_text_editor")  and $(textarea).attr("id") is "post_raw_post"
      true
    else
      false


$(document).ready ->
  $.rte_posts()
