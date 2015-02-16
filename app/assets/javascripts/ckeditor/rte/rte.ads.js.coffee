$.rte_ads = ->
  $('#ad_html').each ->
    CKEDITOR.replace this,
      customConfig: window['CKEDITOR_BASEPATH'] + '/configs/ads.js'

$(document).ready ->
  $.rte_ads()
