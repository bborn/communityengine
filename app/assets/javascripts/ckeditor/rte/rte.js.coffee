$.remove_rte = ->
  try
    for i of CKEDITOR.instances
      do (i) ->
        CKEDITOR.instances[i].destroy(true) if CKEDITOR.instances[i]
  catch error
    console.log "Error: #{error}"


$.save_rte = ->
  try
    for i of CKEDITOR.instances
      do (i) ->
        CKEDITOR.instances[i].updateElement() if CKEDITOR.instances[i]
  catch error
    console.log "Error: #{error}"


$(document).on 'page:receive', ->
  $.remove_rte()
