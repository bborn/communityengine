CKEDITOR.editorConfig = (config) ->
  config.filebrowserImageBrowseUrl = '/manage_photos'
  # The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = '/manage_photos'

  config.allowedContent = true
  # Rails CSRF token

  config.filebrowserParams = ->
    csrf_token = undefined
    csrf_param = undefined
    meta = undefined
    metas = document.getElementsByTagName('meta')
    params = new Object
    i = 0
    while i < metas.length
      meta = metas[i]
      switch meta.name
        when 'csrf-token'
          csrf_token = meta.content
        when 'csrf-param'
          csrf_param = meta.content
        else
          i++
          continue
      i++
    if csrf_param != undefined and csrf_token != undefined
      params[csrf_param] = csrf_token
    params

  config.addQueryString = (url, params) ->
    queryString = []
    if !params
      return url
    else
      for i of params
        queryString.push i + '=' + encodeURIComponent(params[i])
    url + (if url.indexOf('?') != -1 then '&' else '?') + queryString.join('&')

  # Integrate Rails CSRF token into file upload dialogs (link, image, attachment and flash)
  CKEDITOR.on 'dialogDefinition', (ev) ->
    # Take the dialog name and its definition from the event data.
    dialogName = ev.data.name
    dialogDefinition = ev.data.definition
    content = undefined
    upload = undefined
    if CKEDITOR.tools.indexOf([
        'link'
        'image'
        'attachment'
        'flash'
      ], dialogName) > -1
      content = dialogDefinition.getContents('Upload') or dialogDefinition.getContents('upload')
      upload = if content == null then null else content.get('upload')
      if upload and upload.filebrowser and upload.filebrowser['params'] == undefined
        upload.filebrowser['params'] = config.filebrowserParams()
        upload.action = config.addQueryString(upload.action, upload.filebrowser['params'])
    return
  # Toolbar groups configuration.
  config.toolbar = [
    {
      name: 'document'
      groups: [
        'mode'
        'document'
        'doctools'
      ]
      items: [ 'Source' ]
    }
    {
      name: 'clipboard'
      groups: [
        'clipboard'
        'undo'
      ]
      items: [
        'Cut'
        'Copy'
        'Paste'
        'PasteText'
        'PasteFromWord'
        '-'
        'Undo'
        'Redo'
      ]
    }
    {
      name: 'links'
      items: [
        'Link'
        'Unlink'
        'Anchor'
      ]
    }
    {
      name: 'insert'
      items: [
        'Image'
        'Flash'
        'Table'
        'HorizontalRule'
        'SpecialChar'
      ]
    }
    {
      name: 'paragraph'
      groups: [
        'list'
        'indent'
        'blocks'
        'align'
        'bidi'
      ]
      items: [
        'NumberedList'
        'BulletedList'
        '-'
        'Outdent'
        'Indent'
        '-'
        'Blockquote'
        'CreateDiv'
        '-'
        'JustifyLeft'
        'JustifyCenter'
        'JustifyRight'
        'JustifyBlock'
      ]
    }
    '/'
    {
      name: 'styles'
      items: [
        'Styles'
        'Format'
        'Font'
        'FontSize'
      ]
    }
    {
      name: 'colors'
      items: [
        'TextColor'
        'BGColor'
      ]
    }
    {
      name: 'basicstyles'
      groups: [
        'basicstyles'
        'cleanup'
      ]
      items: [
        'Bold'
        'Italic'
        'Underline'
        'Strike'
        'Subscript'
        'Superscript'
        '-'
        'RemoveFormat'
      ]
    }
  ]
  config.toolbar_mini = [
    {
      name: 'paragraph'
      groups: [
        'list'
        'indent'
        'blocks'
        'align'
        'bidi'
      ]
      items: [
        'NumberedList'
        'BulletedList'
        '-'
        'Outdent'
        'Indent'
        '-'
        'Blockquote'
        'CreateDiv'
        '-'
        'JustifyLeft'
        'JustifyCenter'
        'JustifyRight'
        'JustifyBlock'
      ]
    }
    {
      name: 'styles'
      items: [
        'Font'
        'FontSize'
      ]
    }
    {
      name: 'colors'
      items: [
        'TextColor'
        'BGColor'
      ]
    }
    {
      name: 'basicstyles'
      groups: [
        'basicstyles'
        'cleanup'
      ]
      items: [
        'Bold'
        'Italic'
        'Underline'
        'Strike'
        'Subscript'
        'Superscript'
        '-'
        'RemoveFormat'
      ]
    }
    {
      name: 'insert'
      items: [
        'Image'
        'Table'
        'HorizontalRule'
        'SpecialChar'
      ]
    }
  ]
  return
