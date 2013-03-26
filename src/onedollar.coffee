class window.OneDollar


  class Vector
    constructor: (@x=0.0, @y=0.0) ->

    dist: (vector) ->
      return Math.sqrt( Math.pow((vector.x-@x),2) + Math.pow((vector.y-@y),2) )

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

    seperator = (this.___length points) / (@fragmentation-1)

    console.log (@fragmentation-1)
    console.log seperator

    distance = 0.0
    # path = [points[0]]

    # for i in [1...points.length]

    #   space = points[i-1].dist points[i]

    #   console.log 'space', space, '(distance+space)', (distance+space), 'seperator', seperator

    #   if ((distance+space) >= seperator)


    #     x = (points[i-1].x+((seperator-distance)/space)*(points[i].x-points[i-1].x))
    #     y = (points[i-1].y+((seperator-distance)/space)*(points[i].y-points[i-1].y))

    #     point = new Vector(x,y)

    #     console.log point

    #     path[path.length] = point
    #     points.splice i, 0, point
    #     distance = 0.0
    #   else
    #     distance += space
    


    # if path.length is (@fragmentation-1)
    #   path[path] = points[points.length-1]

    # return path

    path = []

    while points.length isnt 0

      pp = points.pop()

      if path.length is 0
        path.push pp
      else

        if points.length is 0
          path.push pp
          return path

        p = points[points.length-1]
        space = pp.dist p

        console.log 'space', space

        console.log 'points.length', points.length, 'distance', distance, 'space', space, 'distance+space', (distance+space), 'seperator', seperator

        if ((distance+space) >= seperator)

          vector = new Vector(pp.x+((seperator-distance)/space)*(p.x-pp.x), pp.y+((seperator-distance)/space)*(p.y-pp.y))
          path.push vector

          points.push vector
          distance = 0

          if path.length is (@fragmentation-1)
            path.push points[points.length-1]
            return path
        else
          distance += space

    return path

    
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