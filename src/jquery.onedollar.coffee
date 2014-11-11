# The library is Open Source Software released under the MIT License.
# It's developed by Darius Morawiec. 2013-2014
#
# https://github.com/voidplus/onedollar-coffeescript

$ = jQuery

$.fn.extend

  onedollar: (data) ->

    return @each ()->

      one = null
      def = 80

      isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

      if isArray data

        length = if data.length is 2 or 3 then data.length else null

        if length isnt null

          one = new window.OneDollar if length is 3 then parseInt data[2] else def

          for template in data[0]
            one.add template[0], template[1]

          for template in data[1]
            one.on template[0], template[1]

      else

        if typeof data.templates isnt 'undefined' and typeof data.binds isnt 'undefined'

          one = new window.OneDollar if typeof data.score isnt 'undefined' then parseInt data.score else def

          for template in data.templates
            one.add template[0], template[1]

          for bind in data.binds
            one.on bind[0], bind[1]

      if one isnt null

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
