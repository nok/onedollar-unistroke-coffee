class window.OneDollar

  typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

  constructor: (@fragmentation=64, @size=250, @angle=45, @step=3) ->
    
    # final/constants
    @PI = Math.PI
    @HALFDIAGONAL = 0.5*Math.sqrt(@size*@size+@size*@size)

    # learned gestures
    @templates = {}

  learn: (name, points) ->
    if typeIsArray points
      points = this._transform points
      @templates[name] = points

  check: (points) ->
    if typeIsArray points
      points = this._transform points

  _transform: (points) ->
    console.log '_transform'
    points = this.__resample points
    points = this.__rotateToZero points
    points = this.__scaleToSquare points
    points = this.__translateToOrigin points
    return points

  __resample: (points) ->
    console.log '__resample'
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
