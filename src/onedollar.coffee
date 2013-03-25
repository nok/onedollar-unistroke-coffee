class window.OneDollar


  class Vector
    constructor: (@x=0, @y=0) ->

    dist: (vector) ->
      return Math.sqrt( Math.pow((@x-@y),2) + Math.pow((vector.x-vector.y),2) )

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
    if this._validate points
      points = this._transform points
      @templates[name] = points


  #
  # run the recognizer
  #
  check: (points) ->
    if this._validate points
      points = this._transform points


  #
  # check, if data isn't a empty array
  #
  _validate: (points) ->
    if typeIsArray points
      if points.length % 2 is 0 and points.length > 0
        return true
    return false


  _transform: (points) ->
    points = this.__convert points
    points = this.__resample points
    # points = this.__rotateToZero points
    # points = this.__scaleToSquare points
    # points = this.__translateToOrigin points
    return points

  __convert: (points) ->
    vectors = []
    for p, i in points by 2
      vectors.push new Vector points[i], points[i+1]
    return vectors

  __resample: (points) ->
    console.log '__resample'

    seperator = (this.___length points) / (@fragmentation-1)

    # console.log centroid

    return points

    
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
    length = 0
    tmp = null

    for p in points
      if tmp isnt null
        length += p.dist tmp
      tmp = p

    return length


  #
  # helpers
  #
  typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'