var gulp = require('gulp');
var plug = require('gulp-load-plugins')();
var notifier = require('node-notifier');

var path = {
  src: 'src',
  dist: 'lib'
};

var error = false;
var onError = function(err) {
  error = true;
  plug.notify.onError({
    title:      'Gulp (onedollar-coffeescript)',
    subtitle:   'Error: <%= error.plugin %>!',
    message:    '<%= error.message %>',
    sound:      true
  })(err);
  this.emit('end');
};

gulp.task('start', function() {
  error = false;
  return gulp;
});

gulp.task('finish', ['report'], function() {
  if(!error) {
    notifier.notify({
      title:    'Gulp (onedollar-coffeescript)',
      message:  'All is fine!',
      sound:    false
    });
    plug.util.log(plug.util.colors.green('All is fine!'));
  } else {
    plug.util.log(plug.util.colors.red('Error!'));
  }
  return gulp;
});

gulp.task('coffee', ['start'], function() {
  return gulp.src(path.src + '/*.coffee')
    .pipe(plug.plumber({errorHandler: onError}))
    .pipe(plug.coffeelint({
      opts: {}
    }))
    .pipe(plug.coffeelint.reporter())
    .pipe(plug.coffeelint.reporter('failOnWarning'))
    .pipe(plug.sourcemaps.init())
    .pipe(plug.coffee({bare: true}).on('error', onError))
    .pipe(plug.sourcemaps.write('./maps'))
    .pipe(gulp.dest(path.dist));
});

gulp.task('uglify', ['coffee'], function() {
  return gulp.src([path.dist + '/*.js', '!' + path.dist + '/*.min.js'])
    .pipe(plug.plumber({errorHandler: onError}))
    .pipe(plug.uglify())
    .pipe(plug.rename({
      suffix: '.min'
    }))
    .pipe(gulp.dest(path.dist))
    .pipe(plug.livereload());
});

gulp.task('test', ['uglify'], function () {
  return gulp.src('test/test.js', {read: false})
    .pipe(plug.plumber({errorHandler: onError}))
    .pipe(plug.mocha({reporter: 'spec'})); // nyan
});

gulp.task('report', ['test'], function() {
  return gulp.src(path.dist + '/*.js')
    .pipe(plug.size({
      gzip: true,
      pretty: true,
      showFiles: true,
      showTotal: false
    }))
    .pipe(plug.size({
      gzip: false,
      pretty: true,
      showFiles: true,
      showTotal: false
    }));
});

gulp.task('watch', function() {
  plug.livereload.listen();
  gulp.watch([path.src + '/*.coffee', 'test/*.js'], ['default']);
});

gulp.task('default', ['start', 'coffee', 'uglify', 'test', 'report', 'finish']);
