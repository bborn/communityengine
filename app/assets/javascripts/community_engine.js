///////////////////////////////////////////
// BASE JAVASCRIPT FUNCTIONALITY         //
///////////////////////////////////////////
//= require jquery
//= require jquery-ui
//= require bootstrap
//= require bootstrap-dropdown
//
///////////////////////////////////////////
// UTILITIES                             //
///////////////////////////////////////////
//= require tinymce-jquery

jQuery.fn.scrollTo = function () {
  space_at_top = $('.navbar').height() + 20;
  $('html,body').animate({scrollTop: $(this).offset().top - space_at_top},'slow');
}


$('.submit-via-ajax').submit(function(){
  console.log('Attempting to save via AJAX...');
  $.ajax({
    type: $(this).attr('method'),
    url: $(this).attr('action').replace('?', '.js?'),
    data: $(this).serialize(),
    dataType: 'script',
    success: function(response) {
      if(response) {
        console.log('Return script received.');
      } else {
        console.log('Failed to receive return script.');
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      console.log(jqXHR);
      console.log(textStatus);
      console.log(errorThrown);
    }
  });
  event.preventDefault();
});

$('.submit-via-ajax').bind('form-pre-serialize', function(e) {
        tinyMCE.triggerSave();
});
