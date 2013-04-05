(function() {
  var $;

  $ = jQuery;

  $.fn.extend({
    onedollar: function(templates) {
      return this.each(function() {
        var candidate, draw, one, template, _i, _len;
        one = new OneDollar;
        for (_i = 0, _len = templates.length; _i < _len; _i++) {
          template = templates[_i];
          one.add(template[0], template[1]);
          one.on(template[0], template[2]);
        }
        candidate = [];
        draw = false;
        return $(this).on('touchstart touchmove touchend', function(e) {
          var touch, type;
          e.preventDefault();
          touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
          type = e.type;
          switch (type) {
            case 'touchstart':
              candidate = [];
              return draw = true;
            case 'touchmove':
              if (draw === true) {
                return candidate.push([touch.pageX, touch.pageY]);
              }
              break;
            case 'touchend':
              draw = false;
              return one.check(candidate);
          }
        });
      });
    }
  });

}).call(this);
