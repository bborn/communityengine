CKEDITOR.editorConfig = (config) ->
  config.startupMode = 'source'
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
