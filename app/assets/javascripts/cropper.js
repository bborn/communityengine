// the following required file can be found at vendor/assets/javascripts/jcrop/jquery.Jcrop.min.js
//= require jcrop/jquery.Jcrop.min

function cropInit() {
  croppable_name = '#' + croppable_id;	
  preview_name = '#' + preview_id;	
	
  // Copy the image, and insert it in an offscreen DIV
  aimgcopy = $(croppable_name).clone();
  $('body').append('<div id="store"></div>')
  $('#store').append(aimgcopy);

  // Remove the height and width attributes
  aimgcopy.removeAttr('height');
  aimgcopy.removeAttr('width');
	
  croppableWidth = aimgcopy.width();
  croppableHeight = aimgcopy.height();
  
  aspectRatio = minWidth/minHeight;
  cropStartRatio = minWidth/croppableWidth;
  cropToPreviewRatio = cropStartRatio / previewRatio;

  cropStartWidth = croppableWidth * cropStartRatio;
  cropStartHeight = cropStartWidth/aspectRatio;
  
  cropStartX1 = (croppableWidth - cropStartWidth)/2;
  cropStartY1 = (croppableHeight - cropStartHeight)/2;
  
  cropStartX2 = cropStartX1 + cropStartWidth;
  cropStartY2 = cropStartY1 + cropStartHeight;

  previewSrc = $(croppable_name).attr('src');

  previewWidth = croppableWidth * previewRatio;
  previewHeight = croppableHeight * previewRatio;
  
  $(preview_name).css('backgroundImage', 'url('+ previewSrc +')');
  $(preview_name).css('backgroundRepeat', 'no-repeat');
  $(preview_name).css('margin', 'auto');
  $(preview_name).css('width', previewWidth + 'px');
  $(preview_name).css('height', previewHeight + 'px');
  
  jcrop_api = $.Jcrop(croppable_name);
  jcrop_api.animateTo([ cropStartX1, cropStartY1, cropStartX2, cropStartY2 ]);
  
  $(croppable_name).Jcrop({
      onSelect:    setCoords,
      onChange:    setCoords,
      onRelease:   setCoords,
      bgColor:     bgColor,
      bgOpacity:   bgOpacity,
      minSize:     [ minWidth, minHeight],
      setSelect:   [0, 0, 0, 0],
      aspectRatio: aspectRatio
  });
}

function setCoords(c) {
  // variables can be accessed here as
  // c.x, c.y, c.x2, c.y2, c.w, c.h
  $('#crop_x').val(c.x);
  $('#crop_y').val(c.y);
  $('#crop_w').val(c.w);
  $('#crop_h').val(c.h);
  showPreview(c);
}

function showPreview(c) {
  currentRatioWidth = croppableWidth / c.w;
  currentRatioHeight = croppableHeight / c.h;
  
  currentCropRatioX = c.w/croppableWidth;
  currentCropToPreviewRatioX = currentCropRatioX / previewRatio;
  
  currentCropRatioY = c.h/croppableHeight;
  currentCropToPreviewRatioY = currentCropRatioY / previewRatio;
  
  previewSizeWidth = previewWidth * currentRatioWidth;
  previewSizeHeight = previewHeight * currentRatioHeight;
  
  previewPositionX = -(c.x/currentCropToPreviewRatioX);
  previewPositionY = -(c.y/currentCropToPreviewRatioY);
  
  $('#preview').css('backgroundSize', previewSizeWidth + 'px ' + previewSizeHeight + 'px');
  $('#preview').css('backgroundPosition', previewPositionX + 'px ' + previewPositionY + 'px');
}
