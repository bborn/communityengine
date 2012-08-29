///////////////////////////////////////////
// BASE JAVASCRIPT FUNCTIONALITY         //
///////////////////////////////////////////
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-dropdown
//
///////////////////////////////////////////
// UTILITIES                             //
///////////////////////////////////////////
//= require tinymce-jquery

function scrollToAnchor(anchor){
  loc = document.location.toString();
  if (loc.indexOf("#") != -1){
    parts = loc.split('#')
    loc = parts[0] + '#' + anchor
  } else {
    loc = loc + '#' + anchor
  }
  document.location.href = loc;
}
