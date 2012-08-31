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

jQuery.fn.keepUpdatedFromUrl = function (url_to_load, frequency) {
	updateElementFromUrl($(this), url_to_load);
	setInterval(
		function() {
			updateElementFromUrl($(this), url_to_load);
		}, 
		frequency
	);
}

function updateElementFromUrl(element, url_to_load) {
	$.get(url_to_load, function(data) {
		element.html(data);
	});
}
	
$('.delete-via-ajax').live('click', function(event){
	event.preventDefault();
	if(confirm($(this).attr('data-manual-confirm'))) {
		console.log('Attempting to delete via AJAX...');
		$.ajax({
			type: 'POST',
			data: {'_method': 'delete'},
			url: $(this).attr('href') + '.js',
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
	}
})


$('.submit-via-ajax').submit(function(){
  event.preventDefault();
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
});

$('.submit-via-ajax').bind('form-pre-serialize', function(e) {
        tinyMCE.triggerSave();
});