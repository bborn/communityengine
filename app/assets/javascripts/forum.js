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