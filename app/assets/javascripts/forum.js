$('.editor-cancel').live('click', function () {
  event.preventDefault();
  post_body_name = '#' + $(this).attr('data-target');
  $(post_body_name).children('.editable').removeClass('hide');
  $(post_body_name).children('.editor').addClass('hide');
});

$('.reply').addClass('hide');

$('.reply-toggle').click(function () {
  event.preventDefault();
  if($('.reply').hasClass('hide')) {
    $('.reply').removeClass('hide');
    $('.reply').scrollTo();
  } else {
    $('.reply').addClass('hide');
  }
});

$('#monitor_checkbox').live('change', function(){
  form = $(this).closest('form');
  if ($(this).is(':checked')) {
    form.attr('method', 'post');
  } else {
    form.attr('method', 'delete');
  }
  submitViaAjax(form);
});