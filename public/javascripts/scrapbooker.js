var prototype_src = 'http://localhost:3000/javascripts/prototype.js?x=' + Math.floor(Math.random() * 9999);
var lightbox_src = 'http://localhost:3000/javascripts/lightbox.js?x=' + Math.floor(Math.random() * 9999);
var lightbox_style = 'http://localhost:3000/stylesheets/lightbox.css?x=' + Math.floor(Math.random() * 9999);
var create_user_clipping_url = 'http://localhost:3000/new_clipping'

var Scrapbooker = {
	init: function(){
		var head = document.getElementsByTagName('head').item(0); 
		var p_script = document.createElement('script'); 		
		p_script.setAttribute('src', prototype_src ); 		
		p_script.setAttribute('type','text/javascript'); 
		head.appendChild(p_script);
		var l_script = document.createElement('script'); 		
		l_script.setAttribute('src',  lightbox_src ); 		
		l_script.setAttribute('type','text/javascript'); 
		head.appendChild(l_script);

		var scrapbooker_style = document.createElement('link'); 		
		scrapbooker_style.setAttribute('href',  lightbox_style ); 		
		scrapbooker_style.setAttribute('rel','stylesheet'); 
		scrapbooker_style.setAttribute('media','screen'); 
		scrapbooker_style.setAttribute('type','text/css'); 		
		head.appendChild(scrapbooker_style);		
	}, 
	
	delayed_init: function(){
		if ( $$ ){
			this.parse();					
			this.restyle_page();
		} else {
			setTimeout("Scrapbooker.delayed_init()", 50);
		}
	},
		
	parse: function(){

		images = $$("img");
		body = $$("body")[0];
		
		images.each(function(image){
			image.onclick = function(event){
				image = Event.element(event)
				Element.addClassName(image, "selectable")
				
				if ($('form_div')){
					Element.remove('form_div');
				}
				
				var form_div = document.createElement('div')
				form_div.id = 'form_div'

				var f = document.createElement('form'); 
				form_div.appendChild(f)
				
				this.parentNode.appendChild(form_div); 
				new Lightbox.base('form_div');
				
				f.method = 'POST'; 
				f.action = create_user_clipping_url;
				var m = document.createElement('input'); 
				m.setAttribute('type', 'hidden'); 
				m.setAttribute('name', '_method'); 
				m.setAttribute('value', 'post'); 
				f.appendChild(m);
				
				var image_url = document.createElement('input'); 
				image_url.setAttribute('name', 'clipping[image_url]');
				image_url.setAttribute('type', 'hidden'); 								 
				image_url.setAttribute('value', image.src); 
				f.appendChild(image_url);

				var u_label = document.createElement('div'); 
				u_label.appendChild(document.createTextNode("URL:"));
				var url = document.createElement('input'); 
				url.setAttribute('name', 'clipping[url]'); 
				url.setAttribute('value', window.location); 
				u_label.appendChild(url)
				f.appendChild(u_label);

				var d_label = document.createElement('div'); 
				d_label.appendChild(document.createTextNode("Description:"));
				var description = document.createElement('input'); 
				description.setAttribute('name', 'clipping[description]'); 
				description.setAttribute('value', ""); 
				d_label.appendChild(description)
				f.appendChild(d_label);

				var t_label = document.createElement('div'); 
				t_label.appendChild(document.createTextNode("Tags:"))
				var tags = document.createElement('input'); 
				tags.setAttribute('id', 'tag_list'); 
				tags.setAttribute('name', 'tag_list'); 
				tags.setAttribute('value', ""); 
				t_label.appendChild(tags)
				f.appendChild(t_label);				
				
				var submit = document.createElement('input'); 
				submit.setAttribute('name', 'submit'); 
				submit.setAttribute('value', 'Save'); 				
				submit.setAttribute('type', 'submit'); 				
				f.appendChild(submit);

				Field.focus('tag_list');				
				new Insertion.Top(form_div, '<img src="'+image.src+'" width="200" style="float:right;" />')
				new Insertion.Top(form_div, '<strong>Add Your Image</strong>')
				//f.submit(); 
			}
			
			body.appendChild(image);

		})

	},
			
	restyle_page: function(){
		$$('style').each(function(element){
			Element.remove(element);
		});
		$$("link").each(function(element){
			if (element.href != lightbox_style){
				Element.remove(element);				
			}
		});
		$$("script").each(function(element){
			if (element.src != prototype_src){
				Element.remove(element);				
			}
		});
		new Insertion.Top(body,'<h3>Click on an image to add it.</h3>');		
		new Insertion.Top(body,"<style> body { background:#ccc;} input { width:250px; } img.selectable { cursor:pointer; cursor:hand; margin:10px;} </style>");
		body = $$('body')[0];
	},
	
	submit_clipping: function(event){
	}	
	
}


Scrapbooker.init();
setTimeout("Scrapbooker.delayed_init()", 50);
