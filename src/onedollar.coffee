"use strict"

class window.OneDollar



  class Vector

    constructor: (@x=0.0, @y=0.0) ->

    dist: (vector) ->
      return Math.sqrt( Math.pow((@x-vector.x),2) + Math.pow((@y-vector.y),2) )

    add: (value) ->
      if value instanceof Vector
        @x += value.x
        @y += value.y
      else
        @x += value
        @y += value
      return @

    div: (value) ->
      if value instanceof Vector
        @x /= value.x
        @y /= value.y
      else
        @x /= value
        @y /= value
      return @

    mult: (value) ->
      if value instanceof Vector
        @x *= value.x
        @y *= value.y
      else
        @x *= value
        @y *= value
      return @



  class Result

    constructor: (@name='', @score=0.0) ->



  constructor: (@fragmentation=64, @size=250, @angle=45, @step=2) ->

    @PI             = Math.PI
    @PHI            = 0.5 * (-1.0+Math.sqrt(5.0))
    @HALFDIAGONAL   = 0.5 * Math.sqrt(@size*@size + @size*@size)
    @templates      = {}


  #
  # 'learn' new gestures
  #
  learn: (name, points) ->

    if points.length > 0
      @templates[name] = @_transform points

    return @


  #
  # run the recognizer
  #
  check: (points) ->

    if points.length > 0
      points = @_transform points
    else
      return false

    difference = +Infinity
    template = null

    for name, template_points of @templates
      space = @__find_best_template points, template_points
      if space < difference
        difference = space
        template = name
        
    if template isnt null
      score = Math.floor( (1.0 - difference / @HALFDIAGONAL)*100 )
      # console.log 'template ', template, ' score', score
      # return points
      return new Result template, score

    return false


  #
  # transform the points
  #
  _transform: (points) ->

    points = @__convert points
    points = @__resample points
    points = @__rotate_to_zero points
    points = @__scale_to_square points
    points = @__translate_to_origin points

    return points


  #
  # convert arrays to vectors
  #
  __convert: (points) ->

    result = []

    for point in points
      result.push new Vector point[0], point[1]

    return result


  #
  # resample the points
  #
  __resample: (points) ->

    seperator = (@___get_length points) / (@fragmentation-1)
    distance = 0
    result = []

    while points.length isnt 0
      prev = points.pop()

      # handle the fix first point
      if result.length is 0
        result.push prev
      else

        # handle the fix last point
        if points.length is 0
          result.push prev
          break

        point = points[points.length-1]
        space = prev.dist point

        if ((distance+space) >= seperator)
          vector = new Vector(prev.x+((seperator-distance)/space)*(point.x-prev.x), prev.y+((seperator-distance)/space)*(point.y-prev.y))
          result.push vector
          points.push vector
          distance = 0

          if result.length is (@fragmentation-1)
            result.push points[points.length-1]
            break

        else
          distance += space

    if result.length isnt @fragmentation
      point = result[result.length-1]
      for i in [result.length...@fragmentation]
        result.push point

    return result


  #
  # rotate the points
  #
  __rotate_to_zero: (points) ->

    centroid = @___get_centroid points
    theta = Math.atan2 centroid.y-points[0].y, centroid.x-points[0].x

    return @___rotate points, -theta, centroid


  #
  # scale the points to the bounding box
  #
  __scale_to_square: (points) ->

    maxX = maxY = -Infinity
    minX = minY = +Infinity
    
    for point in points
      minX = Math.min point.x, minX
      maxX = Math.max point.x, maxX
      minY = Math.min point.y, minY
      maxY = Math.max point.y, maxY
    
    return @___scale points, new Vector @size/(maxX-minX), @size/(maxY-minY)


  #
  # translate the points to origin
  #
  __translate_to_origin: (points) ->

    centroid = @___get_centroid points
    return @___translate points, centroid.mult -1


  #
  # find the best template
  #
  __find_best_template: (points, template_points) ->

    a = @___radians -@angle
    b = @___radians @angle
    treshold = @___radians @step

    c = (1.0-@PHI)*b + @PHI*a
    d = (1.0-@PHI)*a + (@PHI*b)

    path_a = @___get_difference_at_angle points, template_points, c
    path_b = @___get_difference_at_angle points, template_points, d

    if path_a isnt +Infinity and path_b isnt +Infinity
      while Math.abs(b-a)>treshold
        if path_a < path_b
          b = d
          d = c
          path_b = path_a
          c = @PHI*a + (1.0-@PHI)*b
          path_a = @___get_difference_at_angle points, template_points, c
        else
          a = c
          c = d
          path_a = path_b
          d = @PHI*b + (1.0-@PHI)*a
          path_b = @___get_difference_at_angle points, template_points, d
      return Math.min path_a, path_b
    return +Infinity


  #
  # calculate the centroid of a path
  #
  ___get_centroid: (points) ->
    centroid = new Vector
    for p in points
      centroid.add p
    centroid.div points.length
    return centroid


  #
  # calculate the length of a path
  #
  ___get_length: (points) ->

    length = 0.0
    tmp = null

    for p in points
      if tmp isnt null
        length += p.dist tmp
      tmp = p

    return length


  #
  # calculate the difference between two paths at a specific angle
  #  
  ___get_difference_at_angle: (points, template_points, radians) ->

    centroid = @___get_centroid points
    points = @___rotate points, radians, centroid

    return @___get_difference points, template_points


  #
  # calculate the difference between two paths
  #
  ___get_difference: (template, candidate) ->

    distance = 0.0
    for point, i in template
      distance += point.dist candidate[i]

    return distance / template.length


  #
  # translation
  #
  ___translate: (points, offset) ->

    for point in points
      point.add offset

    return points


  #
  # scaling
  #
  ___scale: (points, offset) ->

    for point in points
      point.mult offset

    return points


  #
  # rotation
  #
  ___rotate: (points, radians, pivot) ->

    sin = Math.sin radians
    cos = Math.cos radians

    for point, i in points
      x = (point.x-pivot.x)*cos - (point.y-pivot.y)*sin + pivot.x
      y = (point.x-pivot.x)*sin + (point.y-pivot.y)*cos + pivot.y
      points[i] = new Vector x, y

    return points


  #
  # convert degrees to radians
  #
  ___radians: (degrees) ->

    return degrees * Math.PI / 180.0
