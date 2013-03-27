class window.OneDollar

  class Vector
    constructor: (@x=0.0, @y=0.0) ->

    dist: (vector) ->
      return Math.sqrt( Math.pow((@x-vector.x),2) + Math.pow((@y-vector.y),2) )

    add: (vector) ->
      @x += vector.x
      @y += vector.y
      return this

    div: (number) ->
      @x /= number
      @y /= number
      return this


  constructor: (@fragmentation=64, @size=250, @angle=45, @step=3) ->

    @PI = Math.PI
    @HALFDIAGONAL = 0.5*Math.sqrt(@size*@size+@size*@size)
    @templates = {}


  #
  # 'learn' new gestures
  #
  learn: (name, points) ->
    if points.length > 0
      points = this._transform points
      @templates[name] = points


  #
  # run the recognizer
  #
  check: (points) ->
    if points.length > 0
      points = this._transform points
      return points


  _transform: (points) ->
    points = this.__convert points
    points = this.__resample points

    console.log points.length

    # points = this.__rotateToZero points
    # points = this.__scaleToSquare points
    # points = this.__translateToOrigin points
    return points


  __convert: (points) ->
    vectors = []
    for p in points
      vectors.push new Vector p[0], p[1]
    return vectors


  __resample: (points) ->
    console.log '__resample'

    seperator = (this.___length points)/(@fragmentation-1)
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

    
  __rotateToZero: (points) ->
    console.log '__rotateToZero'
    return points


  __scaleToSquare: (points) ->
    console.log '__scaleToSquare'
    return points



  __translateToOrigin: (points) ->
    console.log '__translateToOrigin'
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
  ___length: (points) ->
    length = 0.0
    tmp = null

    for p in points

      console.log p.x, p.y

      if tmp isnt null
        length += p.dist tmp
      tmp = p

    console.log '=', length

    return length
