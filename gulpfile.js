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

gulp.task('render', function() {
  addsrc('./src/**/*.ejs.*')
    .pipe(data(loadData))
    .pipe(template())
    .pipe(rename(function(path) {
      path.dirname = path.dirname.replace(/^src\//, '')
      path.basename = path.basename.replace(/\.ejs$/, '')
    }))
    .pipe(gulp.dest('./render'))

  addsrc('./src/**/*')
    .pipe(ignore.exclude('**/*.ejs.*'))
    .pipe(rename(function(path) {
      path.dirname = path.dirname.replace(/^src\//, '')
    }))
    .pipe(gulp.dest('./render'))
});

gulp.task('css', function() {
  ['base', 'pictograms'].forEach(function(name) {
    addsrc('./render/css/'+name+'.css')
      .pipe(basswork())
      .pipe(gulp.dest('./build/css'))
      .pipe(minifyCss())
      .pipe(rename({ extname: '.min.css' }))
      .pipe(gulp.dest('./build/css'))
  });
});

gulp.task('js', function() {
  ['app'].forEach(function(name) {
    var browserified = transform(function(filename) {
      var b = browserify(filename);
      return b.bundle();
    });
    addsrc('./render/js/'+name+'.js')
      .pipe(browserified)
      .pipe(uglify())
      .pipe(rename({ extname: '.min.js' }))
      .pipe(gulp.dest('./build/js'))
  });
});

gulp.task('html', function() {
  addsrc('./render/*.html')
    .pipe(escapeHTMLSnippets)
    .pipe(gulp.dest('./build/'))
});

gulp.task('build', ['css', 'js', 'html'], function() {
  addsrc('./fonts/**/*')
    .pipe(gulp.dest('./build/fonts'))
  addsrc('./images/**/*')
    .pipe(gulp.dest('./build/images'))
});

gulp.task('serve', function() {
  addsrc('./build')
    .pipe(webserver({ port: (process.env.PORT || '8000'), open: true }))
});

gulp.task('default', ['serve'], function() {
  gulp.watch(['./src/**/*'], ['render']);
  gulp.watch(['./render/**/*'], ['build']);
});

gulp.task('dist', function() {
});
