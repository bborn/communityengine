///////////////////////////////////////////
// BASE JAVASCRIPT FUNCTIONALITY         //
///////////////////////////////////////////
//= require jquery
//= require jquery.migrate
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap-sprockets
//
///////////////////////////////////////////
// UTILITIES                             //
///////////////////////////////////////////
//= require tinymce-jquery

(function($){

  $.CE = {};

  jQuery.fn.RichTextEditor = function (options) {
    $this = $(this);
    // fix tinymce bug with html5 and required fields
    if($this.is("[required]")){
        options.oninit = function(editor){
            $this.closest("form").find(":submit").on("click", function(){
              editor.save();
            });
        }
    }
    $this.tinymce(options);
  }

  jQuery.fn.scrollTo = function () {
    space_at_top = $('.navbar').height() + 20;
    $('html,body').animate({scrollTop: $(this).offset().top - space_at_top},'slow');
  }

  jQuery.fn.keepUpdatedFromUrl = function (url_to_load, frequency) {
    updateElementFromUrl($(this), url_to_load);
    setInterval(
      function() {
        $(this).updateFromUrl(url_to_load);
      },
      frequency
    );
  }

  jQuery.fn.updateFromUrl = function(url_to_load) {
    element = this;
    $.get(url_to_load, function(data) {
      $(element).html(data);
    });
  }

  $(document).on('click', '.delete-via-ajax', function(event){
    event.preventDefault();
    if(confirm($(this).attr('data-manual-confirm'))) {
      console.log('Attempting to delete via AJAX...');
      $.ajax({
        type: 'POST',
        data: {'_method': 'delete'},
        beforeSend: function(xhr, settings) {
          xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
        },
        url: $(this).attr('href') + '.js',
          dataType: 'script',
          success: function(response) {
            if(response) {
              console.log('Return script received.');
            } else {
              console.log('Failed to receive return script.');
            }
          },
          error: logError
      });
    }
  })

  $(document).on('submit', '.submit-via-ajax', function(event){
    event.preventDefault();
    submitViaAjax($(this));
  });

  $('.submit-via-ajax').bind('form-pre-serialize', function(e) {
    tinyMCE.triggerSave();
  });

  $(document).on('click', '.edit-via-ajax', function(){
    event.preventDefault();
    console.log('Attempting to retrieve edit form via AJAX...');
    $('#'+ $(this).attr('id') + '_spinner').removeClass('hide');
    $.ajax({
      type: $(this).attr('method'),
      url: $(this).attr('href').replace('?', '.js?'),
      dataType: 'script',
      success: function(response) {
        if(response) {
          console.log('Return script received.');
        } else {
          console.log('Failed to receive return script.');
        }
      },
      error: logError
    });
  });

  $(document).on('click', '.act-via-ajax', function(event){
    event.preventDefault();
    console.log('Attempting to act via AJAX...');
    $this = $(this);
    $('#'+ $this.attr('id') + '_spinner').removeClass('hide');
    if($this.is("input") || $this.is("button")) {
      action = $this.closest('form').attr('action');
      method = $this.closest('form').attr('method');
    } else if ($this.is("a")) {
      action = $this.attr('href');
      method = $this.attr('data-method');
    } else {
      console.log('Could not identify element type.');
      return false;
    }
    $.ajax({
      type: method,
      url: action.replace('?', '.js?'),
      dataType: 'js',
      success: function(response) {
        if(response) {
          $this.effect("pulsate", { times:1 }, 250);
          $this.replaceWith(response);
          $('#' + $this.attr('id')).effect("pulsate", { times:2 }, 500);
        } else {
          console.log('Failed to receive return script.');
        }
      },
      error: logError
    });
  });

  $(document).on('click', '.check-all', function(e){
    e.preventDefault();
    first_val = $(this).closest('form').find(':checkbox').attr('checked');
    if(first_val) {
      new_val = false
    } else {
      new_val = 'checked'
    }
    $(this).closest('form').find(':checkbox').attr('checked', new_val);
  });

})(jQuery);


function updateElementFromPost(element, url_to_load) {
  $('#'+element.attr('id')+'_spinner').removeClass('hide');
  $.ajax({
    type: 'POST',
    url: url_to_load,
    dataType: 'html',
    success: function(data) {
    element.html(data);
      $('#'+element.attr('id')+'_spinner').addClass('hide');
  },
    error: logError
  });
}

function submitViaAjax(form) {
  $('#'+ form.attr('id') + '_spinner').removeClass('hide');
  console.log('Attempting to save via AJAX...');
  $.ajax({
    type: form.attr('method'),
    url: form.attr('action').replace('?', '.js?'),
    data: form.serialize(),
    dataType: 'script',
    success: function(response) {
      if(response) {
        console.log('Return script received.');
      } else {
        console.log('Failed to receive return script.');
      }
    },
    error: logError
  });
}

function logError(jqXHR, textStatus, errorThrown) {
  console.log(jqXHR);
  console.log(textStatus);
  console.log(errorThrown);
}
