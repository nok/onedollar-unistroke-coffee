(function() {
  var $;

  $ = jQuery;

  $.fn.extend({
    onedollar: function(templates) {
      return this.each(function() {
        var mouse_click, one, template, touch_event, _i, _len;
        one = new OneDollar;
        for (_i = 0, _len = templates.length; _i < _len; _i++) {
          template = templates[_i];
          one.add(template[0], template[1]);
          one.on(template[0], template[2]);
        }
        mouse_click = false;
        touch_event = 'ontouchstart' in document.documentElement ? true : false;
        return $(this).on('mousedown mousemove mouseup touchstart touchmove touchend', function(e) {
          var i, touch, touches, _j, _len1, _results;
          e.preventDefault();
          if (touch_event) {
            touches = e.originalEvent.changedTouches;
            _results = [];
            for (i = _j = 0, _len1 = touches.length; _j < _len1; i = ++_j) {
              touch = touches[i];
              switch (e.type) {
                case 'touchstart':
                  _results.push(one.start(i, [touch.pageX, touch.pageY]));
                  break;
                case 'touchmove':
                  _results.push(one.update(i, [touch.pageX, touch.pageY]));
                  break;
                case 'touchend':
                  _results.push(one.end(i, [touch.pageX, touch.pageY]));
                  break;
                default:
                  _results.push(void 0);
              }
            }
            return _results;
          } else {
            switch (e.type) {
              case 'mousedown':
                mouse_click = true;
                return one.start(0, [e.pageX, e.pageY]);
              case 'mousemove':
                if (mouse_click === true) {
                  return one.update(0, [e.pageX, e.pageY]);
                }
                break;
              case 'mouseup':
                if (mouse_click === true) {
                  one.end(0, [e.pageX, e.pageY]);
                  return mouse_click = false;
                }
            }
          }
        });
      });
    }
  });

}).call(this);
