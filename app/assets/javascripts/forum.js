$('.editor-toggle').click(function () {
  event.preventDefault();
  post_body_name = '#' + $(this).attr('data-target');
  if($(post_body_name).children('.editor').hasClass('hide')) {
    $('.editable').removeClass('hide');
    $('.editor').addClass('hide');
    $(post_body_name).children('.editable').addClass('hide');
    $(post_body_name).children('.editor').removeClass('hide');
  } else {
    $(post_body_name).children('.editable').removeClass('hide');
    $(post_body_name).children('.editor').addClass('hide');
  }
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