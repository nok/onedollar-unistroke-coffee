var $;

$ = jQuery;

$.fn.extend({
  onedollar: function(data) {
    return this.each(function() {
      var bind, callback, click, el, events, hasBinds, hasOptions, hasTemplates, j, len, name, one, ref, ref1, template, templates, touch;
      one = null;
      hasTemplates = typeof data.templates === 'object';
      hasBinds = typeof data.on === 'object' || typeof data.on === 'function';
      if (hasTemplates && hasBinds) {
        hasOptions = typeof data.options !== 'undefined';
        one = new window.OneDollar(hasOptions ? data.options : {});
        ref = data.templates;
        for (name in ref) {
          template = ref[name];
          one.add(name, template);
        }
        if (typeof data.on === 'function') {
          one.on('*', data.on);
        } else {
          ref1 = data.on;
          for (j = 0, len = ref1.length; j < len; j++) {
            bind = ref1[j];
            templates = bind[0];
            callback = bind[1];
            if (typeof templates === 'string' && typeof callback === 'function') {
              one.on(templates, callback);
            }
          }
        }
        click = false;
        el = document.documentElement;
        touch = 'ontouchstart' in el ? true : false;
        events = 'mousedown mousemove mouseup touchstart touchmove touchend';
        $(this).on(events, function(e) {
          var i, k, len1, results, touches;
          e.preventDefault();
          if (touch) {
            touches = e.originalEvent.changedTouches;
            results = [];
            for (i = k = 0, len1 = touches.length; k < len1; i = ++k) {
              touch = touches[i];
              switch (e.type) {
                case 'touchstart':
                  results.push(one.start(i, [touch.pageX, touch.pageY]));
                  break;
                case 'touchmove':
                  results.push(one.update(i, [touch.pageX, touch.pageY]));
                  break;
                case 'touchend':
                  results.push(one.end(i, [touch.pageX, touch.pageY]));
                  break;
                default:
                  results.push(void 0);
              }
            }
            return results;
          } else {
            switch (e.type) {
              case 'mousedown':
                click = true;
                return one.start(0, [e.pageX, e.pageY]);
              case 'mousemove':
                if (click === true) {
                  return one.update(0, [e.pageX, e.pageY]);
                }
                break;
              case 'mouseup':
                if (click === true) {
                  one.end(0, [e.pageX, e.pageY]);
                  return click = false;
                }
            }
          }
        });
        return this;
      }
    });
  }
});

//# sourceMappingURL=maps/jquery.onedollar.js.map
