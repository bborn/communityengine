// EventSelectors 
// Copyright (c) 2005-2006 Justin Palmer (http://encytemedia.com)
// Examples and documentation (http://encytemedia.com/event-selectors)
// 
// EventSelectors allow you access to Javascript events using a CSS style syntax.
// It goes one step beyond Javascript events to also give you :loaded, which allows 
// you to wait until an item is loaded in the document before you begin to interact
// with it.
//
// Inspired by the work of Ben Nolan's Behaviour (http://bennolan.com/behaviour)
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

// Probably want to remove these and create your own.
var Rules = {
  
  '#icons a:mouseover': function(element) {
    var app = element.id;
    new Effect.BlindDown(app + '-content', {queue: 'end', duration: 0.2});
  },
  
  '#icons a:mouseout': function(element) {
    var app = element.id;
    new Effect.BlindUp(app + '-content', {queue: 'end', duration: 0.2});
  },
  
  '#features:mouseover': function(element) {
    //alert('wee mouse');
  },
  
  '#features': function(element) {
    Sortable.create(element);
  },
  
  '#features li:click': function(element, event) {
    new Ajax.Updater('features', 'item.html', {
      asynchronous:true, 
      method: 'get', 
      evalScripts: true, 
      insertion: Insertion.Bottom
    });
  }
}

var EventSelectors = {
  version: '1.0_pre',
  cache: [],
  
  start: function(rules) {
    this.rules = rules || {};
    this.timer = new Array();
    this._extendRules();
    this.assign(this.rules);
  },
  
  assign: function(rules) {
    var observer = null;
    this._unloadCache();
    rules._each(function(rule) {
      var selectors = $A(rule.key.split(','));
      selectors.each(function(selector) {        
        var pair = selector.split(':');
        var event = pair[1];
        $$(pair[0]).each(function(element) {
          if(pair[1] == '' || pair.length == 1) return rule.value(element);
          if(event.toLowerCase() == 'loaded') {
            this.timer[pair[0]] = setInterval(this._checkLoaded.bind(this, element, pair[0], rule), 15);
          } else {
            observer = function(event) {
              var element = Event.element(event);
              if (element && element.nodeType == 3) // Safari Bug (Fixed in Webkit)
            		element = element.parentNode;
              rule.value($(element), event);
            }
            if (element){
            		this.cache.push([element, event, observer]);	
								Event.observe(element, event, observer);	
							}
          }
        }.bind(this));
      }.bind(this));
    }.bind(this));
  },
  
  // Scoped caches would rock.
  _unloadCache: function() {
    if (!this.cache) return;
    for (var i = 0; i < this.cache.length; i++) {
      Event.stopObserving.apply(this, this.cache[i]);
      this.cache[i][0] = null;
    }
    this.cache = [];
  },
  
  _checkLoaded: function(element, timer, rule) {
    var node = $(element);
    if(element.tagName != 'undefined') {
      clearInterval(this.timer[timer]);
      rule.value(node);
    }
  },
  
  _extendRules: function() {
    Object.extend(this.rules, {
     _each: function(iterator) {
       for (key in this) {
         if(key == '_each') continue;         
         var value = this[key];
         var pair = [key, value];
         pair.key = key;
         pair.value = value;
         iterator(pair);
       }
     }  
    });
  }
}

// Remove/Comment this if you do not wish to reapply Rules automatically
// on Ajax request.
Ajax.Responders.register({
  onComplete: function() { EventSelectors.assign(Rules);}
});