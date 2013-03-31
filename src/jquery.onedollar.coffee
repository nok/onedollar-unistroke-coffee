$ = jQuery

$.fn.extend

  onedollar: (templates) ->

    return @each ()->

      one = new OneDollar

      for template in templates
        one.add template[0], template[1]
        one.on template[0], template[2]

      candidate = []
      draw = false

      $(this).on 'touchstart touchmove touchend', (e) ->
        e.preventDefault()

        touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
        type = e.type
        
        switch type
          when 'touchstart'
            candidate = []
            draw = true
          when 'touchmove'
            if draw is true
              candidate.push [touch.pageX, touch.pageY]
          when 'touchend'
            draw = false
            one.check candidate