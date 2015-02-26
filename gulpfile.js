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

var loadData = function(file, cb) {
  var csv = fs.readFileSync('./src/pictograms.csv', 'utf8');
  parse(csv, {}, function(err, csvData) {
    if (err) { return cb(err); }

    var data = {
      pictograms: csvData
    };

    cb(undefined, data);
  });
};

gulp.task('ejs', function() {
  gulp.src('./src/**/*.ejs.*')
    .pipe(data(loadData))
    .pipe(template())
    .pipe(rename(function(path) {
      path.dirname = path.dirname.replace(/^src\//, '');
      path.basename = path.basename.replace(/\.ejs$/, '');
    }))
    .pipe(gulp.dest('./src'))
});

gulp.task('css', ['ejs'], function() {
  ["base", "pictograms"].forEach(function(name) {
    gulp.src('./src/css/'+name+'.css')
      .pipe(basswork())
      .pipe(gulp.dest('./css'))
      .pipe(minifyCss())
      .pipe(rename({ extname: '.min.css' }))
      .pipe(gulp.dest('./css'))
  });
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

gulp.task('html', ['ejs'], function() {
  gulp.src('./src/*.html')
    .pipe(gulp.dest('.'))
});

gulp.task('dist', ['make'], function() {
  gulp.src(['./css/base*css', './css/pictograms*css'])
    .pipe(gulp.dest('./dist'))
});

gulp.task('serve', function() {
  gulp.src('.')
    .pipe(webserver({ port: (process.env.PORT || '8000') }));
});

gulp.task('make', ['css', 'js', 'html']);

gulp.task('default', ['make', 'serve'], function() {
  gulp.watch(['./src/**/*'], ['css', 'js', 'html']);
});

