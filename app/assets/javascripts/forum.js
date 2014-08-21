$(document).on('click', '.editor-cancel', function () {
  event.preventDefault();
  post_body_name = '#' + $(this).attr('data-target');
  $(post_body_name).find('.editable').removeClass('hide');
  $(post_body_name).find('.editor').addClass('hide');
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

$(document).on('click', '#monitor_checkbox', function () {
  form = $(this).closest('form');
  if ($(this).is(':checked')) {
    form.attr('method', 'post');
  } else {
    form.attr('method', 'delete');
  }
  submitViaAjax(form);
});
