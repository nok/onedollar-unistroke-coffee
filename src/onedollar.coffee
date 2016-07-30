# The library is Open Source Software released under the MIT License.
# It's developed by Darius Morawiec. 2013-2016
#
# https://github.com/nok/onedollar-coffeescript
#
# ---
#
# The $1 Gesture Recognizer is a research project by Wobbrock, Wilson and Li of
# the University of Washington and Microsoft Research. It describes a simple
# algorithm for accurate and fast recognition of drawn gestures.
#
# Gestures can be recognised at any position, scale, and under any rotation.
# The system requires little training, achieving a 97% recognition rate with
# only one template for each gesture.
#
# http://depts.washington.edu/aimgroup/proj/dollar/



class OneDollar


  # Math constants:
  PHI = 0.5 * (-1.0 + Math.sqrt(5.0))

  # Prepared inner variables:
  SIZE = HALF = ANGLE = STEP = null

  # Internal data handlers:
  _options = {}
  _templates = {}
  _binds = {}
  _hasBinds = false
  _candidates = []


  # The constructor of the algorithm.
  #
  # @param {[object]} options  The options of the algorithm.
  #
  # @return OneDollar
  constructor: (options = {}) ->
    _options = options

    # Threshold in percent of callbacks:
    if !('score' of _options)
      _options['score'] = 80

    if !('parts' of _options)
      _options['parts'] = 64

    if !('angle' of _options)
      _options['angle'] = 45
    ANGLE = ___radians _options.angle

    if !('step' of _options)
      _options['step'] = 2
    STEP = ___radians _options.step

    # Size of bounding box:
    if !('size' of _options)
      _options['size'] = 250.0
    SIZE = _options.size
    HALF = 0.5 * Math.sqrt(SIZE * SIZE + SIZE * SIZE)

    return @


  # Add a new template.
  #
  # @param {String} name  The name of the template.
  # @param {Array} points  The points of the gesture.
  #
  # @return OneDollar
  add: (name, points) ->
    if points.length > 0
      _templates[name] = _transform points
    return @


  # Remove a template.
  #
  # @param {String} name  The name of the template.
  #
  # @return OneDollar
  remove: (name) ->
    if _templates[name] isnt undefined
      delete _templates[name]
    return @


  # Bind callback for chosen templates.
  #
  # @param {String} name  The name of the template.
  # @param {function} fn  The callback function.
  #
  # @return OneDollar
  on: (name, fn) ->
    names = []
    if name == "*"
      for name, template of _templates
        names.push name
    else
      names = name.split ' '

    for name in names
      if _templates[name] isnt undefined
        _binds[name] = fn
        _hasBinds = true
      else
        throw new Error "The template '" + name + "' isn't defined."
    return @


  # Unbind callback for chosen templates.
  #
  # @param {String} name  The name of the template.
  #
  # @return OneDollar
  off: (name) ->
    if _binds[name] isnt undefined
      delete _binds[name]
      _hasBinds = false
      for name, bind of _binds
        if _templates.hasOwnProperty name
          _hasBinds = true
          break
    return @


  # Get information about the algorithm.
  #
  # @return Object  Return options, templates and binds.
  toObject: ->
    return {
      options: _options
      templates: _templates
      binds: _binds
    }


  # Create a new gesture candidate.
  #
  # @param {Integer} id   The unique ID of the candidate.
  # @param {Array} point  The start position of the candidate.
  #
  # @return OneDollar
  start: (id, point) ->
    if typeof(id) is 'object' and typeof(point) is 'undefined'
      point = id
      id = -1
    _candidates[id] = []
    @update id, point
    return @


  # Add a new position to a created candidate.
  #
  # @param {Integer} id   The unique ID of the candidate.
  # @param {Array} point  The new position of the candidate.
  #
  # @return OneDollar
  update: (id, point) ->
    if typeof(id) is 'object' and typeof(point) is 'undefined'
      point = id
      id = -1
    _candidates[id].push point
    return @


  # Close a new gesture candidate and trigger the gesture recognition.
  #
  # @param {Integer} id   The unique ID of the candidate.
  # @param {Array} point  The last position of the candidate.
  #
  # @return OneDollar
  end: (id, point) ->
    if typeof(id) is 'object' and typeof(point) is 'undefined'
      point = id
      id = -1
    @update id, point
    result = @check _candidates[id]
    delete _candidates[id]
    return result


  # Run the gesture recognition.
  #
  # @param {Array} candidate The candidate gesture.
  #
  # @return {boolean|Object} The result object.
  check: (candidate) ->
    args = false
    points = candidate.length
    if points < 3
      return args

    path =
      start: [candidate[0][0], candidate[0][1]]
      end: [candidate[points - 1][0], candidate[points - 1][1]]
      centroid: if points > 1 then ___centroid candidate else path.start
    candidate = _transform candidate

    ranking = []
    bestDist = +Infinity
    bestName = null
    for name, template of _templates
      if _hasBinds == false or _binds[name] isnt undefined
        distance = _findBestMatch candidate, template
        score = parseFloat(((1.0 - distance / HALF) * 100).toFixed(2))
        if isNaN score
          score = 0.0
        ranking.push
          name: name
          score: score
        if distance < bestDist
          bestDist = distance
          bestName = name

    if ranking.length > 0
      # Sorting:
      if ranking.length > 1
        ranking.sort (a, b) ->
          return if a.score < b.score then 1 else -1

      idx = candidate.length - 1
      args =
        name: ranking[0].name
        score: ranking[0].score
        recognized: false
        path: path
        ranking: ranking

      if ranking[0].score >= _options.score
        args.recognized = true
        if _hasBinds
          _binds[ranking[0].name].apply @, [args]

    return args


  # Transform the data  to a comparable format.
  #
  # @param {Array} points The raw candidate gesture.
  #
  # @return Array The transformed candidate.
  _transform = (points) ->                 # Algorithm step:
    points = __resample points             # (1)
    points = __rotateToZero points       # (2)
    points = __scaleToSquare points      # (3)
    points = __translateToOrigin points  # (4)
    return points


  # Find the best match between a candidate and template.
  #
  # @param {Array} candidate The candidate gesture.
  # @param {Array} template  The template gesture.
  #
  # @return Float The computed smallest distance.
  _findBestMatch = (candidate, template) ->
    rt = ANGLE
    lt = -ANGLE

    centroid = ___centroid candidate
    x1 = PHI * lt + (1.0 - PHI) * rt
    f1 = __distanceAtAngle candidate, template, x1, centroid
    x2 = (1.0 - PHI) * lt + PHI * rt
    f2 = __distanceAtAngle candidate, template, x2, centroid

    while (Math.abs(rt - lt) > STEP)
      if f1 < f2
        rt = x2
        x2 = x1
        f2 = f1
        x1 = PHI * lt + (1.0 - PHI) * rt
        f1 = __distanceAtAngle candidate, template, x1, centroid
      else
        lt = x1
        x1 = x2
        f1 = f2
        x2 = (1.0 - PHI) * lt + PHI * rt
        f2 = __distanceAtAngle candidate, template, x2, centroid
    return Math.min(f1, f2)


  # 1: Resampling of a gesture.
  #
  # @param {Array} points The points of a move.
  #
  # @return Array The resampled gesture.
  __resample = (points) ->
    seperator = (___length points) / (_options.parts - 1)
    distance = 0.0
    resampled = []
    resampled.push [points[0][0], points[0][1]]
    idx = 1
    while idx < points.length
      prev = points[idx - 1]
      point = points[idx]
      space = ___distance(prev, point)
      if (distance + space) >= seperator
        x = prev[0] + ((seperator - distance) / space) * (point[0] - prev[0])
        y = prev[1] + ((seperator - distance) / space) * (point[1] - prev[1])
        resampled.push [x, y]
        points.splice idx, 0, [x, y]
        distance = 0.0
      else
        distance += space
      idx += 1

    while resampled.length < _options.parts
      resampled.push [points[points.length-1][0], points[points.length-1][1]]

    return resampled


  # 2: Rotation of the gesture.
  #
  # @param {Array} points The points of a move.
  #
  # @return Array The rotated gesture.
  __rotateToZero = (points) ->
    centroid = ___centroid points
    theta = Math.atan2(centroid[1] - points[0][1], centroid[0] - points[0][0])
    return ___rotate points, -theta, centroid


  # 3: Scaling of a gesture.
  #
  # @param {Array} points The points of a move.
  #
  # @return Array The scaled gesture.
  __scaleToSquare = (points) ->
    minX = minY = +Infinity
    maxX = maxY = -Infinity
    for point in points
      minX = Math.min(point[0], minX)
      maxX = Math.max(point[0], maxX)
      minY = Math.min(point[1], minY)
      maxY = Math.max(point[1], maxY)
    deltaX = maxX - minX
    deltaY = maxY - minY

    offset = [SIZE / deltaX, SIZE / deltaY]
    return ___scale points, offset


  # 4: Translation of a gesture.
  #
  # @param {Array} points The points of a move.
  #
  # @return Array The translated gesture.
  __translateToOrigin = (points) ->
    centroid = ___centroid points
    centroid[0] *= -1
    centroid[1] *= -1
    return ___translate points, centroid


  # Compute the delta space between two sets of points at a specific angle.
  #
  # @param {Array} points1 The points of a move.
  # @param {Array} points2 The points of a move.
  # @param {Float} radians The radian value.
  #
  # @return Float The computed distance.
  __distanceAtAngle = (points1, points2, radians, centroid) ->
    _points1 = ___rotate points1, radians, centroid
    result = ___delta _points1, points2
    return result


  # Compute the delta space between two sets of points.
  #
  # @param {Array} points1 The points of a move.
  # @param {Array} points2 The points of a move.
  #
  # @return Float The computed distance.
  ___delta = (points1, points2) ->
    delta = 0.0
    for point, idx in points1
      delta += ___distance(points1[idx], points2[idx])
    return delta / points1.length


  # Compute the distance of a gesture.
  #
  # @param {Array} points The points of a move.
  #
  # @return Float The computed distance.
  ___length = (points) ->
    length = 0.0
    prev = null
    for point in points
      if prev isnt null
        length += ___distance(prev, point)
      prev = point
    return length


  # Compute the euclidean distance between two points.
  #
  # @param {Array} p1 The first two dimensional point.
  # @param {Array} p2 The second two dimensional point.
  #
  # @return Float The computed euclidean distance.
  ___distance = (p1, p2) ->
    x = Math.pow(p1[0] - p2[0], 2)
    y = Math.pow(p1[1] - p2[1], 2)
    return Math.sqrt(x + y)


  # Compute the centroid of a set of points.
  #
  # @param {Array} points1 The points of a move.
  #
  # @return Array The centroid object.
  ___centroid = (points) ->
    x = 0.0
    y = 0.0
    for point in points
      x += point[0]
      y += point[1]
    x /= points.length
    y /= points.length
    return [x, y]


  # Rotate a gesture.
  #
  # @param {Array} points  The points of a move.
  # @param {Float} radians The rotation angle.
  # @param {Array} pivot   The pivot of the rotation.
  #
  # @return Array The rotated gesture.
  ___rotate = (points, radians, pivot) ->
    sin = Math.sin(radians)
    cos = Math.cos(radians)
    neew = []
    for point, idx in points
      deltaX = points[idx][0] - pivot[0]
      deltaY = points[idx][1] - pivot[1]
      points[idx][0] = deltaX * cos - deltaY * sin + pivot[0]
      points[idx][1] = deltaX * sin + deltaY * cos + pivot[1]
    return points


  # Scale a gesture.
  #
  # @param {Array} points The points of a move.
  # @param {Array} offset The scalar values.
  #
  # @return Array The scaled gesture.
  ___scale = (points, offset) ->
    for point, idx in points
      points[idx][0] *= offset[0]
      points[idx][1] *= offset[1]
    return points


  # Translate a gesture.
  #
  # @param {Array} points The points of a move.
  # @param {Array} offset The translation values.
  #
  # @return Array The translated gesture.
  ___translate = (points, offset) ->
    for point, idx in points
      points[idx][0] += offset[0]
      points[idx][1] += offset[1]
    return points


  # Compute the radians from degrees.
  #
  # @param {Float} degrees The degree value.
  #
  # @return Float The computed radian value.
  ___radians = (degrees) ->
    return degrees * Math.PI / 180.0


# Environment and testing:
if typeof exports isnt 'undefined'
  exports.OneDollar = OneDollar
