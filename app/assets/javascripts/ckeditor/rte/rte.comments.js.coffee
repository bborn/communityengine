$.rte_comments = ->
  CKEDITOR.replaceAll (textarea, config) ->
    config.customConfig = window['CKEDITOR_BASEPATH'] + '/configs/comments.js'
    if $(textarea).hasClass("rich_text_editor")  and $(textarea).attr("id") is "comment_comment"
      true
    else
      false


$(document).ready ->
  $.rte_comments()
