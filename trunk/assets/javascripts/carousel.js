// Copyright (c) 2006 Sébastien Gruhier (http://xilinus.com, http://itseb.com)
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// VERSION 0.20

var Carousel = Class.create();
Carousel.prototype = {
  // Constructor
  initialize: function(carouselElemID) {
    this.carouselElemID = carouselElemID;
    
    this.options = Object.extend({
      numVisible:           4,
      scrollInc:            3,
      animParameters:      {},
      buttonStateHandler:  null,
      animHandler:         null,
      ajaxHandler:         null,
      queue:               "carousel",
      size:                0,
      prevElementID:       "prev-arrow",
      nextElementID:       "next-arrow",
      ajaxParameters:      null,
      url:                 null
		}, arguments[1] || {});

		this.initDone = false;
		this.animRunning = "none";
    this.requestIsRunning = false;
    
		// add afterFinish options to animParameters (store old function)
		this.animAfterFinish = this.options.animParameters.afterFinish;
		Object.extend(this.options.animParameters, {afterFinish:  this._animDone.bind(this), queue: { position:'end', scope: this.options.queue }});
	  
		// Event bindings
		this.prevScroll = this._prevScroll.bindAsEventListener(this);
		this.nextScroll = this._nextScroll.bindAsEventListener(this);
		this.onComplete = this._onComplete.bindAsEventListener(this);
		this.onFailure  = this._onFailure.bindAsEventListener(this);

		Event.observe(this.options.prevElementID, "click", this.prevScroll);
		Event.observe(this.options.nextElementID, "click", this.nextScroll);
		
		// Get DOM UL element
		var carouselListClass = "carousel-list";
		this.carouselList = document.getElementsByClassName(carouselListClass, $(carouselElemID))[0]
		
		// Init data
		this._init();
  },
  
  // Destructor
 	destroy: function() {
  	Event.stopObserving(this.options.prevElementID, "click", this.prevScroll);
  	Event.stopObserving(this.options.nextElementID, "click", this.nextScroll);
	},
	
  /* "Private" functions */
  _init: function() {
    this.currentIndex = 0;
    
      
    // Ajax content
    if (this.options.url)
  	  this._request(this.currentIndex, this.options.numVisible);
	  // Static content
  	else {
  	  this._getLiElementSize();
  		this._updateButtonStateHandler(this.options.prevElementID, false);
  		this._updateButtonStateHandler(this.options.nextElementID, this.options.size > this.options.numVisible);
  	}
  },
  
  _prevScroll: function(event) {
    if (this.animRunning != "none" || this.currentIndex == 0)
      return;

    var inc = this.options.scrollInc;

    if (this.currentIndex - inc < 0)
      inc = this.currentIndex;

    this._scroll(inc)		  
	  return false;
  },
  
  _nextScroll: function(event) {    
    if (this.animRunning != "none")
      return false;
            
    // Check if there are enough elements in cache
    if (this.currentIndex + this.options.numVisible + this.options.scrollInc <= this.options.size) 
      this._scroll(-this.options.scrollInc);
    else {
      // Compute how many are in the cache
      this.nbInCache = this.options.size - (this.currentIndex + this.options.numVisible);
      if (this.options.url && this.noMoreImages == false) 
		    this._request(this.currentIndex + this.options.numVisible + this.nbInCache, this.options.scrollInc - this.nbInCache);
	    else  {
	      if (this.nbInCache > 0)
          this._scroll(-this.nbInCache);
        }
	  }
	  return false;
  },
  
  _request: function(start, nb) {
    if (this.options.url && ! this.requestIsRunning) {
      this.requestIsRunning = true;
      
      if (this.options.ajaxHandler)
        this.options.ajaxHandler(this, "before");
      
      var params = "start=" + start + "&nb=" + nb;
      if (this.options.ajaxParameters != null)
        params += "&" + this.options.ajaxParameters
      
  		new Ajax.Request(this.options.url, {parameters: params, onComplete: this.onComplete, onFailure: this.onFailure});
		}
  },
  
  _onComplete: function(originalRequest){
    this.requestIsRunning = false;
    this.carouselList.innerHTML += originalRequest.responseText;
    // Compute how many new elements we have
    var size = this.options.size;
    this.options.size = this.carouselList.getElementsByTagName("li").length;
    var inc = this.options.size - size;
    
		// First run, compute li size
		if (this.initDone == false) {
  		this._getLiElementSize()
  		this.currentIndex = 0;
  		this.initDone = true;

  		// Update button states
		  this._updateButtonStateHandler(this.options.prevElementID, false);
		  this._updateButtonStateHandler(this.options.nextElementID, this.options.size == this.options.numVisible);
		  this.noMoreImages = this.options.size < this.options.numVisible
		}
		// Add images
		else {
		  this.noMoreImages = inc != this.options.scrollInc
		  // Add images
		  if (inc > 0) {
        this._scroll(-inc, this.noMoreImages)
      }
      // No more images, disable next button
		  else {
		    if (this.nbInCache >0)
          this._scroll(-this.nbInCache, true);
		    
		    this._updateButtonStateHandler(this.options.nextElementID, false);
	    }
		}
		if (this.options.ajaxHandler)
      this.options.ajaxHandler(this, "after");
  },
  
  _onFailure: function(originalRequest){    
    this.requestIsRunning = false;
  },

  _animDone: function(event){   
    if (this.options.animHandler)
      this.options.animHandler(this.carouselElemID, "after", this.animRunning);
     
    this.animRunning = "none";
    // Call animAfterFinish if exists
    if (this.animAfterFinish)
      this.animAfterFinish(event);
  },
  
  _updateButtonStateHandler: function(button, state) {
		if (this.options.buttonStateHandler) 
		    this.options.buttonStateHandler(button, state)
   },
  
  _scroll: function(delta, forceDisableNext) {      
    this.animRunning = delta > 0 ? "prev" : "next";
    
    if (this.options.animHandler)
      this.options.animHandler(this.carouselElemID, "before", this.animRunning);

    new Effect.MoveBy(this.carouselList, 0, delta * this.elementSize, this.options.animParameters);
    this.currentIndex -= delta;
    this._updateButtonStateHandler(this.options.prevElementID, this.currentIndex != 0);
    
    if (this.options.url && this.noMoreImages == false)
      enable = true;
    else
      enable = (this.currentIndex + this.options.numVisible < this.options.size);
    this._updateButtonStateHandler(this.options.nextElementID, (forceDisableNext ? false : enable));
  },
  
  _getLiElementSize: function() {
    var li = $(this.carouselList.getElementsByTagName("li")[0]);
		if (li){
			this.elementSize = li.getDimensions().width + parseFloat(li.getStyle("margin-left")) + + parseFloat(li.getStyle("margin-right"));			
		}
  }
}
	



