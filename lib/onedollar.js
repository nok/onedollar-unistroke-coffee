(function() {
  "use strict";
  window.OneDollar = (function() {
    var Vector;

    Vector = (function() {

      function Vector(x, y) {
        this.x = x != null ? x : 0.0;
        this.y = y != null ? y : 0.0;
      }

      Vector.prototype.dist = function(vector) {
        return Math.sqrt(Math.pow(this.x - vector.x, 2) + Math.pow(this.y - vector.y, 2));
      };

      Vector.prototype.add = function(value) {
        if (value instanceof Vector) {
          this.x += value.x;
          this.y += value.y;
        } else {
          this.x += value;
          this.y += value;
        }
        return this;
      };

      Vector.prototype.div = function(value) {
        if (value instanceof Vector) {
          this.x /= value.x;
          this.y /= value.y;
        } else {
          this.x /= value;
          this.y /= value;
        }
        return this;
      };

      Vector.prototype.mult = function(value) {
        if (value instanceof Vector) {
          this.x *= value.x;
          this.y *= value.y;
        } else {
          this.x *= value;
          this.y *= value;
        }
        return this;
      };

      return Vector;

    })();

    function OneDollar(score, parts, size, angle, step) {
      if (score == null) {
        score = 80;
      }
      if (parts == null) {
        parts = 64;
      }
      if (size == null) {
        size = 250;
      }
      if (angle == null) {
        angle = 45;
      }
      if (step == null) {
        step = 2;
      }
      this.VERSION = "1.0.1";
      this.config = {
        score: score
      };
      this.MATH = {
        PHI: 0.5 * (-1.0 + Math.sqrt(5.0)),
        HALFDIAGONAL: 0.5 * Math.sqrt(size * size + size * size)
      };
      this.ALGO = {
        parts: parts,
        size: size,
        angle: angle,
        step: step
      };
      this.temps = {};
      this.binds = {};
    }

    OneDollar.prototype.add = function(name, points) {
      if (points.length > 0) {
        this.temps[name] = this._transform(points);
      }
      return this;
    };

    OneDollar.prototype.remove = function(name) {
      if (this.temps[name] !== void 0) {
        delete this.temps[name];
      }
      return this;
    };

    OneDollar.prototype.on = function(name, fn) {
      this.binds[name] = fn;
      return this;
    };

    OneDollar.prototype.off = function(name) {
      if (this.binds[name] !== void 0) {
        delete this.binds[name];
      }
      return this;
    };

    OneDollar.prototype.check = function(points) {
      var args, equality, name, ranking, raw, space, template, template_points, _ref;
      raw = points;
      if (points.length > 0) {
        points = this._transform(points);
      } else {
        return false;
      }
      equality = +Infinity;
      template = null;
      ranking = [];
      _ref = this.temps;
      for (name in _ref) {
        template_points = _ref[name];
        if (this.binds[name] !== void 0) {
          space = this.__find_best_template(points, template_points);
          if (space < equality) {
            equality = space;
            template = name;
          }
          ranking.push({
            name: name,
            score: parseFloat(((1.0 - space / this.MATH.HALFDIAGONAL) * 100).toFixed(2))
          });
        }
      }
      if (template !== null) {
        ranking.sort(function(a, b) {
          if (a.score < b.score) {
            return 1;
          } else {
            return -1;
          }
        });
        if (ranking[0].score >= this.config.score) {
          args = {
            name: ranking[0].name,
            score: ranking[0].score,
            path: {
              start: new Vector(raw[0][0], raw[0][1]),
              end: new Vector(raw[raw.length - 1][0], raw[raw.length - 1][1]),
              centroid: this.___get_centroid(this.__convert(raw))
            },
            ranking: ranking
          };
          this.binds[template].apply(this, [args]);
          return args;
        }
      }
      return false;
    };

    OneDollar.prototype._transform = function(points) {
      points = this.__convert(points);
      points = this.__resample(points);
      points = this.__rotate_to_zero(points);
      points = this.__scale_to_square(points);
      points = this.__translate_to_origin(points);
      return points;
    };

    OneDollar.prototype.__convert = function(points) {
      var point, result, _i, _len;
      result = [];
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        result.push(new Vector(point[0], point[1]));
      }
      return result;
    };

    OneDollar.prototype.__resample = function(points) {
      var distance, i, point, prev, result, seperator, space, vector, _i, _ref, _ref1;
      seperator = (this.___get_length(points)) / (this.ALGO.parts - 1);
      distance = 0;
      result = [];
      while (points.length !== 0) {
        prev = points.pop();
        if (result.length === 0) {
          result.push(prev);
        } else {
          if (points.length === 0) {
            result.push(prev);
            break;
          }
          point = points[points.length - 1];
          space = prev.dist(point);
          if ((distance + space) >= seperator) {
            vector = new Vector(prev.x + ((seperator - distance) / space) * (point.x - prev.x), prev.y + ((seperator - distance) / space) * (point.y - prev.y));
            result.push(vector);
            points.push(vector);
            distance = 0;
            if (result.length === (this.ALGO.parts - 1)) {
              result.push(points[points.length - 1]);
              break;
            }
          } else {
            distance += space;
          }
        }
      }
      if (result.length !== this.ALGO.parts) {
        point = result[result.length - 1];
        for (i = _i = _ref = result.length, _ref1 = this.ALGO.parts; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
          result.push(point);
        }
      }
      return result;
    };

    OneDollar.prototype.__rotate_to_zero = function(points) {
      var centroid, theta;
      centroid = this.___get_centroid(points);
      theta = Math.atan2(centroid.y - points[0].y, centroid.x - points[0].x);
      return this.___rotate(points, -theta, centroid);
    };

    OneDollar.prototype.__scale_to_square = function(points) {
      var maxX, maxY, minX, minY, point, _i, _len;
      maxX = maxY = -Infinity;
      minX = minY = +Infinity;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        minX = Math.min(point.x, minX);
        maxX = Math.max(point.x, maxX);
        minY = Math.min(point.y, minY);
        maxY = Math.max(point.y, maxY);
      }
      return this.___scale(points, new Vector(this.ALGO.size / (maxX - minX), this.ALGO.size / (maxY - minY)));
    };

    OneDollar.prototype.__translate_to_origin = function(points) {
      var centroid;
      centroid = this.___get_centroid(points);
      return this.___translate(points, centroid.mult(-1));
    };

    OneDollar.prototype.__find_best_template = function(points, template_points) {
      var a, b, c, d, path_a, path_b, treshold;
      a = this.___radians(-this.ALGO.angle);
      b = this.___radians(this.ALGO.angle);
      treshold = this.___radians(this.ALGO.step);
      c = (1.0 - this.MATH.PHI) * b + this.MATH.PHI * a;
      d = (1.0 - this.MATH.PHI) * a + (this.MATH.PHI * b);
      path_a = this.___get_difference_at_angle(points, template_points, c);
      path_b = this.___get_difference_at_angle(points, template_points, d);
      if (path_a !== +Infinity && path_b !== +Infinity) {
        while (Math.abs(b - a) > treshold) {
          if (path_a < path_b) {
            b = d;
            d = c;
            path_b = path_a;
            c = this.MATH.PHI * a + (1.0 - this.MATH.PHI) * b;
            path_a = this.___get_difference_at_angle(points, template_points, c);
          } else {
            a = c;
            c = d;
            path_a = path_b;
            d = this.MATH.PHI * b + (1.0 - this.MATH.PHI) * a;
            path_b = this.___get_difference_at_angle(points, template_points, d);
          }
        }
        return Math.min(path_a, path_b);
      }
      return +Infinity;
    };

    OneDollar.prototype.___get_centroid = function(points) {
      var centroid, p, _i, _len;
      centroid = new Vector;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        p = points[_i];
        centroid.add(p);
      }
      centroid.div(points.length);
      return centroid;
    };

    OneDollar.prototype.___get_length = function(points) {
      var length, p, tmp, _i, _len;
      length = 0.0;
      tmp = null;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        p = points[_i];
        if (tmp !== null) {
          length += p.dist(tmp);
        }
        tmp = p;
      }
      return length;
    };

    OneDollar.prototype.___get_difference_at_angle = function(points, template_points, radians) {
      var centroid;
      centroid = this.___get_centroid(points);
      points = this.___rotate(points, radians, centroid);
      return this.___get_difference(points, template_points);
    };

    OneDollar.prototype.___get_difference = function(template, candidate) {
      var distance, i, point, _i, _len;
      distance = 0.0;
      for (i = _i = 0, _len = template.length; _i < _len; i = ++_i) {
        point = template[i];
        distance += point.dist(candidate[i]);
      }
      return distance / template.length;
    };

    OneDollar.prototype.___translate = function(points, offset) {
      var point, _i, _len;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        point.add(offset);
      }
      return points;
    };

    OneDollar.prototype.___scale = function(points, offset) {
      var point, _i, _len;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        point.mult(offset);
      }
      return points;
    };

    OneDollar.prototype.___rotate = function(points, radians, pivot) {
      var cos, i, point, sin, x, y, _i, _len;
      sin = Math.sin(radians);
      cos = Math.cos(radians);
      for (i = _i = 0, _len = points.length; _i < _len; i = ++_i) {
        point = points[i];
        x = (point.x - pivot.x) * cos - (point.y - pivot.y) * sin + pivot.x;
        y = (point.x - pivot.x) * sin + (point.y - pivot.y) * cos + pivot.y;
        points[i] = new Vector(x, y);
      }
      return points;
    };

    OneDollar.prototype.___radians = function(degrees) {
      return degrees * Math.PI / 180.0;
    };

    return OneDollar;

  })();

}).call(this);
