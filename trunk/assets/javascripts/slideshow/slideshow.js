Slideshow = Class.create();
Object.extend(Object.extend(Slideshow.prototype, Abstract.prototype), {
	initialize: function(element, images, options){
		this.timer = null;
	    this.element = $(element);
	    this.options = Object.extend({
	    	frequency: 4,
			transition: true
		}, options || {});
		
		this.counter = 0;
		this.images = images;
		this.id = "#" + this.element.id;
		this.slideshow_image = $$(this.id + ' img.slideshow_image')[0]
		
		if (this.options.debug){
			console.log("this.element %d", this.element)
			console.log("this.id: %d", this.id)
			console.log("this.images %d",this.images)
			console.log("this.slideshow_image %d", this.slideshow_image)
		}
		this.start();
	},
	
	stop: function()
	{
		clearTimeout(this.timer);
	},
	
	start: function()
	{
		this.periodicallyUpdate();
	},
	
	periodicallyUpdate: function()
	{ 
		
		this.update();	
		if (this.images.length == 1)
		{
			return;
		}
		if (this.timer != null)
		{
			clearTimeout(this.timer);		
		}
		this.timer = setTimeout(this.periodicallyUpdate.bind(this), this.options.frequency*1000);		
	},

	currentFeature: function()
	{
	    return this.images[ Math.abs(this.counter) % this.images.length ];
	},	

	fadeInImage: function(){
		this.slideshow_image.src = this.currentFeature()[1];
		new Effect.Grow(this.slideshow_image);
//	new Effect.Opacity(this.slideshow_image, {duration:0.1, from:0, to:1 });		
	},
	
	transitionImage: function(){
		new Effect.Shrink(this.slideshow_image, {afterFinish: this.fadeInImage.bind(this) });
//	new Effect.Opacity(this.slideshow_image, {duration:0.9, from:1.0, to:0.01, afterFinish: this.fadeInImage.bind(this) });
	},

	update: function()
	{
		currentlyAt = this.currentFeature();	
		
		if (currentlyAt && (this.counter != 0) ) {
			if (this.options.transition) {
				this.transitionImage()
			}
		
			if (this.options.debug) {
				console.log("currently at: %d", currentlyAt );	
			}
		} else {
			if (this.options.debug) {
				console.log("Debug: current_feature is nil");	
			}			
			this.slideshow_image.src = this.currentFeature()[1];						
			$$(this.id + ' span#loading')[0].hide();			
		}
    ++this.counter;				
	}	
});
