var gulp = require('gulp');
var rename = require('gulp-rename');
var basswork = require('gulp-basswork');
var minifyCss = require('gulp-minify-css');
var browserify = require('browserify');
var transform = require('vinyl-transform');
var uglify = require('gulp-uglify');
var webserver = require('gulp-webserver');
var template = require('gulp-template');
var data = require('gulp-data');
var fs = require('fs');
var parse = require('csv-parse');


gulp.task('css', function() {
  gulp.src('./src/css/base.css')
    .pipe(basswork())
    .pipe(gulp.dest('./css'))
    .pipe(minifyCss())
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./css'));

  gulp.src('./src/css/pictograms.css')
    .pipe(data(function(file, cb) {
      var csv = fs.readFileSync('./src/pictograms.csv', 'utf8');
      parse(csv, {}, function(err, data) {
        if (err) { return cb(err); }
        cb(undefined, { pictograms: data });
      });
    }))
    .pipe(template())
    .pipe(basswork())
    .pipe(gulp.dest('./css'))
    .pipe(minifyCss())
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./css'));
});

gulp.task('js', function() {
  var browserified = transform(function(filename) {
    var b = browserify(filename);
    return b.bundle();
  });
  gulp.src('./src/js/app.js')
    .pipe(browserified)
    .pipe(uglify())
    .pipe(rename({ extname: '.min.js' }))
    .pipe(gulp.dest('./js'));
});

gulp.task('html', function() {
  gulp.src('./src/index.html')
    .pipe(data(function(file, cb) {
      var csv = fs.readFileSync('./src/pictograms.csv', 'utf8');
      parse(csv, {}, function(err, data) {
        if (err) { return cb(err); }
        cb(undefined, { pictograms: data });
      });
    }))
    .pipe(template())
    .pipe(gulp.dest('.'))
});

gulp.task('serve', function() {
  gulp.src('.')
    .pipe(webserver({}));
});

gulp.task('default', ['css', 'js', 'html', 'serve'], function() {
  gulp.watch(['./src/**/*'], ['css', 'js', 'html']);
});

