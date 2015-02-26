var gulp = require('gulp');
var addsrc = require('gulp-add-src');
var rename = require('gulp-rename');
var ignore = require('gulp-ignore');
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

var escape = require('escape-html');
var through = require('through2');

var escapeHTMLSnippets = (function() {
  var regex = /[\s\S]```([a-z]*)([\s\S]*?)```[\s\S]/gm;
  var strip = function(what) {
    return String(what).replace(/^\s+|\s+$/g, '');
  }
  var replacer = function(match, language, content) {
    return '<pre class="blue" data-lang="' + language + '"><code>' +
           strip(escape(strip(content))) +
           '</code></pre>';
  };
  var pre = function(contents) {
    return contents.replace(regex, replacer);
  };

  return through.obj(function(file, enc, cb) {
    if (file.isBuffer()) {
      var data = pre(file.contents.toString());
      file.contents = new Buffer(data);
    }

    if (file.isStream()) {
      file.contents = file.contents.pipe(through(function(data, enc, next) {
        if (Buffer.isBuffer(data)) {
          data = data.toString();
        }
        this.push(pre(data));
        next();
      },
      function(next) {
        next();
      }));
    }

    cb(null, file);
  });
})();

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
  addsrc('./src/**/*.ejs.*')
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
    addsrc('./src/css/'+name+'.css')
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
  addsrc('./src/js/app.js')
    .pipe(browserified)
    .pipe(uglify())
    .pipe(rename({ extname: '.min.js' }))
    .pipe(gulp.dest('./js'));
});

gulp.task('html', ['ejs'], function() {
  addsrc('./src/*.html')
    .pipe(escapeHTMLSnippets)
    .pipe(ignore.exclude('**/*.ejs.*'))
    .pipe(gulp.dest('.'))
});

gulp.task('make', ['ejs', 'css', 'js', 'html']);

gulp.task('default', ['make']);

