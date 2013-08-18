var $;

$ = jQuery;

$.fn.extend({
  onedollar: function(data) {
    return this.each(function() {
      var bind, def, isArray, length, mouse_click, one, template, touch_event, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
      one = null;
      def = 80;
      isArray = Array.isArray || function(value) {
        return {}.toString.call(value) === '[object Array]';
      };
      if (isArray(data)) {
        length = data.length === 2 || 3 ? data.length : null;
        if (length !== null) {
          one = new window.OneDollar(length === 3 ? parseInt(data[2]) : def);
          _ref = data[0];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            template = _ref[_i];
            one.add(template[0], template[1]);
          }
          _ref1 = data[1];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            template = _ref1[_j];
            one.on(template[0], template[1]);
          }
        }
      } else {
        if (typeof data.templates !== 'undefined' && typeof data.binds !== 'undefined') {
          one = new window.OneDollar(typeof data.score !== 'undefined' ? parseInt(data.score) : def);
          _ref2 = data.templates;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            template = _ref2[_k];
            one.add(template[0], template[1]);
          }
          _ref3 = data.binds;
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            bind = _ref3[_l];
            one.on(bind[0], bind[1]);
          }
        }
      }
      if (one !== null) {
        mouse_click = false;
        touch_event = 'ontouchstart' in document.documentElement ? true : false;
        return $(this).on('mousedown mousemove mouseup touchstart touchmove touchend', function(e) {
          var i, touch, touches, _len4, _m, _results;
          e.preventDefault();
          if (touch_event) {
            touches = e.originalEvent.changedTouches;
            _results = [];
            for (i = _m = 0, _len4 = touches.length; _m < _len4; i = ++_m) {
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
      }
    });
  }
});
