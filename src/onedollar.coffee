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

    constructor: (@name='', @percent=0.0) ->



  constructor: (@fragmentation=64, @size=250, @angle=45, @step=3) ->

    @PI = Math.PI
    @HALFDIAGONAL = 0.5*Math.sqrt(@size*@size+@size*@size)
    @templates = {}


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
      return 

    result = @__equality points

    return points


  #
  # transform the points of the move
  #
  _transform: (points) ->

    points = @__convertToVectors points
    points = @__resample points
    points = @__rotateToZero points
    points = @__scaleToSquare points
    points = @__translateToOrigin points

    return points


  #
  # convert arrays to vectors
  #
  __convertToVectors: (points) ->

    result = []

    for point in points
      result.push new Vector point[0], point[1]

    return result


  #
  # resample the points
  #
  __resample: (points) ->

    seperator = (@___distance points)/(@fragmentation-1)
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
  __rotateToZero: (points) ->

    centroid = @___centroid points
    theta = Math.atan2 centroid.y-points[0].y, centroid.x-points[0].x

    return @___rotate points, -theta, centroid


  #
  # scale the points to the bounding box
  #
  __scaleToSquare: (points) ->

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
  __translateToOrigin: (points) ->

    centroid = @___centroid points
    return @___translate points, centroid.mult -1


  #
  # calculate the best equality between candidate and templates
  #
  __equality: (points) ->
    for name, template of @templates
      for point in template
        console.log point
    return points


  #
  # calculate the centroid of a path
  #
  ___centroid: (points) ->
    centroid = new Vector
    for p in points
      centroid.add p
    centroid.div points.length
    return centroid


  #
  # calculate the length of a path
  #
  ___distance: (points) ->
    length = 0.0
    tmp = null
    for p in points
      if tmp isnt null
        length += p.dist tmp
      tmp = p
    return length


  #
  # calculate the difference between two paths
  #
  ___difference: (template, candidate) ->
    distance = 0.0
    for point, i in template
      distance += point.dist candidate[i]
    return distance/template.length


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
