$ = jQuery

$.fn.extend

  onedollar: (options) ->

    settings =
      score: 80

    settings = $.extend settings, options

    return @each () ->
      #todo