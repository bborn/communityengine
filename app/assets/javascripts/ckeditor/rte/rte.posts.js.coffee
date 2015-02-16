$.rte_posts = ->
  CKEDITOR.replaceAll (textarea, config) ->
    config.customConfig = window['CKEDITOR_BASEPATH'] + '/configs/posts.js'
    if $(textarea).hasClass("rich_text_editor")  and $(textarea).attr("id") is ("post_raw_post" or 'page_body' or 'homepage_feature_description' or 'user_description')
      true
    else
      false


$(document).ready ->
  $.rte_posts()
