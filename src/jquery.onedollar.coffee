# The library is Open Source Software released under the MIT License.
# It's developed by Darius Morawiec. 2013-2016
#
# https://github.com/nok/onedollar-coffeescript

$ = jQuery
$.fn.extend
  onedollar: (data) ->
    return @each () ->
      one = null

      hasTemplates = typeof(data.templates) is 'object'
      hasBinds = typeof(data.on) is 'object' or typeof(data.on) is 'function'

      if hasTemplates and hasBinds
        # Instance:
        hasOptions = typeof(data.options) isnt 'undefined'
        one = new window.OneDollar if hasOptions then data.options else {}

        # Templates:
        for name, template of data.templates
          one.add name, template

        # Binds:
        if typeof(data.on) is 'function'
          one.on '*', data.on
        else
          for bind in data.on
            templates = bind[0]
            callback = bind[1]
            if typeof(templates) is 'string' and typeof(callback) is 'function'
              one.on templates, callback

        click = false
        el = document.documentElement
        touch = if 'ontouchstart' of el then true else false

        events = 'mousedown mousemove mouseup touchstart touchmove touchend'
        $(this).on events, (e) ->
          e.preventDefault()
          if touch
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
                click = true
                one.start 0, [e.pageX, e.pageY]
              when 'mousemove'
                if click is true
                  one.update 0, [e.pageX, e.pageY]
              when 'mouseup'
                if click is true
                  one.end 0, [e.pageX, e.pageY]
                  click = false

        return @
