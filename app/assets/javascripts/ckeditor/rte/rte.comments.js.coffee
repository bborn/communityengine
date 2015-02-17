$.rte_comments = ->
  $('.rich_text_editor[name*=comment]').each ->
    CKEDITOR.replace this,
      customConfig : window['CKEDITOR_BASEPATH'] + '/configs/comments.js'


$(document).ready ->
  $.rte_comments()
