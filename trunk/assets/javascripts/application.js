// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var CommunityEngine = {	
	resize_image: function(img, options ) {
		this.options = options || {};

		var img_width = img.offsetWidth;
		var img_height = img.offsetHeight;
		var img_aspect_ratio = Math.round((img_width / img_height) * 100) / 100;

		var max_width = this.options['max_width'] || 120;
		var max_height = this.options['max_height'] || 90;
		var max_aspect_ratio = Math.round((max_width / max_height) * 100) / 100;

	//	alert("orig image size is " + img_width + "x" + img_height + "\n" + "aspect ratio is " + img_aspect_ratio + "\n\n" + "max image size is " + max_width + "x" + max_height + "\n" + "max aspect ratio is " + max_aspect_ratio);

		var new_img_width = 0;
		var new_img_height = 0;
		var new_aspect_ratio = 0;

		// if no resize needed
    if (img_width < 120 && img_height < 90) {
            new_img_width = img_width;
            new_img_height = img_height; 

		// if wider
		} else if (img_aspect_ratio > max_aspect_ratio) {
			new_img_width = max_width;
			new_img_height = Math.round(new_img_width / img_aspect_ratio);

		// if taller
		} else if (img_aspect_ratio < max_aspect_ratio) {
			new_img_height = max_height;
			new_img_width = Math.round(new_img_height * img_aspect_ratio);

		// equal
		} else {
			new_img_width = max_width;
			new_img_height = max_height;
		}

		img.style.width = new_img_width + "px";
		img.style.height = new_img_height + "px";
		new_aspect_ratio = Math.round((new_img_width / new_img_height) * 100) / 100;
	}	
}

var Cookie = {
	set: function(name,value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
	},

	get: function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	},

	destroy: function(name) {
		createCookie(name,"",-1);
	}	
}

CommunityEngine.ToggleInput = Class.create();
Object.extend(Object.extend(CommunityEngine.ToggleInput.prototype, Abstract.prototype), {
	initialize: function(element, text){
		this.element = $(element);
		this.text = text;
		Event.observe(this.element, 'focus', this.toggleInput.bindAsEventListener(this) );
		Event.observe(this.element, 'blur', this.toggleInput.bindAsEventListener(this) );						
	},
	
	toggleInput: function(event){
		if (event.type == 'focus'){
			this.element.value = (this.element.value == this.text) ? '' : this.element.value;
		} else if (event.type == 'blur'){
			this.element.value = (this.element.value == '') ? this.text : this.element.value;								
		}
	}
	
});

CommunityEngine.FeatureRotator = Class.create();
Object.extend(Object.extend(CommunityEngine.FeatureRotator.prototype, Abstract.prototype), {
	initialize: function(element, features, options){
		this.timer = null;
	    this.element = $(element);
	    this.options = Object.extend({
	    	frequency: 8,
			transition: true
		}, options || {});
		
		this.counter = 0;
		this.features = features;
		this.id = "#" + this.element.id;
		
		if (this.options.debug){
			console.log("this.element %d", this.element)
			console.log("this.id: %d", this.id)
			console.log("this.features %d",this.features)
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
		if (this.features.length == 1)
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
	    return this.features[ Math.abs(this.counter) % this.features.length ];
	},	

	fadeInImage: function(){
		Element.removeClassName(this.new_feature, 'hidden')
		Element.addClassName(this.new_feature, 'showing')	
		Element.removeClassName(this.current_feature, 'showing')
		Element.addClassName(this.current_feature, 'hidden')		
		new Effect.Opacity(this.current_feature, {duration:0.1, from:0, to:1 });		
	},
	
	transitionImage: function(){
		new Effect.Opacity(this.current_feature, {duration:0.9, from:1.0, to:0.01, afterFinish: this.fadeInImage.bind(this) });
	},

	update: function()
	{
		current = $$('.homepage_features .showing')[0]
		this.current_feature = current;

		currentlyAt = this.currentFeature();	
		new_current = $('feature_'+currentlyAt[0])
		this.new_feature = new_current;
		this.new_feature_bg_src = currentlyAt[1];
		
		if (currentlyAt && (this.counter != 0) ) {
			if (this.options.transition) {
				this.transitionImage()
			} else {
					if (this.current_feature){
						Element.removeClassName(this.current_feature, 'showing')
						Element.addClassName(this.current_feature, 'hidden')
					}
					Element.removeClassName(this.new_feature, 'hidden')
					Element.addClassName(this.new_feature, 'showing')	
			}
		
			if (this.options.debug) {
				console.log("currently at: %d", currentlyAt );	
			}
		} else {
			if (this.options.debug) {
				console.log("Debug: current_feature is nil");	
			}			
		}
    ++this.counter;				
	}	
});


