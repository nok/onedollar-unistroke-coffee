# The library is Open Source Software released under the MIT License.
# It's developed by Darius Morawiec. 2013-2014
# 
# https://github.com/voidplus/onedollar-coffeescript

$ = jQuery

$.fn.extend

  onedollar: (templates) ->

    return @each ()->

      one = new OneDollar

      for template in templates
        one.add template[0], template[1]
        one.on template[0], template[2]

      mouse_click = false
      touch_event = if 'ontouchstart' of document.documentElement then true else false

      $(this).on 'mousedown mousemove mouseup touchstart touchmove touchend', (e) ->
        e.preventDefault()

        if touch_event

          touches = e.originalEvent.changedTouches
          for touch, i in touches
            switch e.type
              when 'touchstart'
                one.start i, [touch.pageX, touch.pageY]
              when 'touchmove'
                one.update i, [touch.pageX, touch.pageY]
              when 'touchend'
                one.end i, [touch.pageX, touch.pageY]

        else

          switch e.type
            when 'mousedown'
              mouse_click = true
              one.start 0, [e.pageX, e.pageY]
            when 'mousemove'
              if mouse_click is true
                one.update 0, [e.pageX, e.pageY]
            when 'mouseup'
              if mouse_click is true
                one.end 0, [e.pageX, e.pageY]
                mouse_click = false