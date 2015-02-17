$.rte_posts = ->
  try
    CKEDITOR.replaceAll (textarea, config) ->
      config.customConfig = window['CKEDITOR_BASEPATH'] + '/configs/posts.js'
      if $(textarea).hasClass("rich_text_editor") and $(textarea).attr("name") in ["post[raw_post]", 'page[body]', 'homepage_feature[description\]', 'user[description]', 'sb_post[body]']
        true
      else
        false
  catch error
    console.log "Error: #{error}"


$(document).ready ->
  $.rte_posts()
