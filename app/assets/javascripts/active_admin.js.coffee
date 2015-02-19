#= require active_admin/base
#= require jquery.turbolinks
#= require turbolinks
#= require ckeditor/init
#= require tag-it/tag-it
#= require_directory ./ckeditor/rte

$(document).on 'page:receive', ->
  $('input#tags').each ->
    $.ajax
      type: 'get'
      url: $(this).data('auto_complete_url')
      success: (data) ->
        $(this).tagit
          availableTags: data
          allowSpaces: true
          tagLimit: '20'
          stopWritingOnTagLimit: true
        return
