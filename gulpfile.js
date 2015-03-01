var gulp = require('gulp');
var rename = require('gulp-rename');
var ignore = require('gulp-ignore');
var basswork = require('gulp-basswork');
var minifyCss = require('gulp-minify-css');
var fileinclude = require('gulp-file-include');
var browserify = require('browserify');
var transform = require('vinyl-transform');
var uglify = require('gulp-uglify');
var webserver = require('gulp-webserver');
var data = require('gulp-data');
var fs = require('fs');
var parse = require('csv-parse');
var _ = require('lodash');

var escape = require('escape-html');
var through = require('through2');

var escapeHTMLSnippets = (function() {
  var regex = /[\s\S]```([a-z]*)(\{[^}]+\})?([\s\S]*?)```[\s\S]/gm;
  var strip = function(what) {
    return String(what).replace(/^\s+|\s+$/g, '');
  }
  var replacer = function(match, language, options, content) {
    if (options) {
      options = JSON.parse(options);
    } else {
      options = {};
    }

    var html = '<pre class="blue" data-lang="' + language + '"><code>' +
               strip(escape(strip(content))) +
               '</code></pre>';

    if (options.insert) {
      html = content + html;
    }

    return html;
  };
  var pre = function(contents) {
    var newContents = contents.replace(regex, replacer);
    if (newContents) {
      return newContents;
    } else {
      return contents;
    }
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
  var csv = fs.readFileSync('./pictograms.csv', 'utf8');
  parse(csv, {}, function(err, csvData) {
    if (err) { return cb(err); }

    var data = {
      pictograms: csvData
    };

    pictogramsData = data;

    cb(undefined, data);
  });
};

var template = function() {
  function execTemplate(string, data, emit) {
    var tmpl = _.template(string);
    try {
      var result = tmpl(data);
    } catch (err) {
      emit('error', err, {fileName: file.path});
    }
    return result
  }

  return through.obj(function(file, enc, cb) {
    if (file.isBuffer()) {
      file.contents = new Buffer(execTemplate(file.contents.toString(), file.data, this.emit));
    }

    if (file.isStream()) {
      var self = this;
      file.contents = file.contents.pipe(through(function(contents, enc, next) {
        if (Buffer.isBuffer(contents)) {
          contents = contents.toString();
        }
        this.push(execTemplate(contents, file.data, self.emit));
        next();
      }));
    }

    cb(null, file);
  });
}

gulp.task('render', function() {
  gulp.src(['./src/**/*'])
    .pipe(fileinclude({
      prefix: '@@',
      basePath: '@file'
    }))
    .pipe(data(loadData))
    .pipe(template())
    .pipe(rename(function(path) {
      path.dirname = path.dirname.replace(/^src\//, '')
    }))
    .pipe(gulp.dest('./render'))
});

gulp.task('css', function() {
  var names = ['essentials', 'pictograms'].map(function(name) { return './render/css/'+name+'.css' });
  gulp.src(names)
    .pipe(basswork())
    .pipe(gulp.dest('./build/css'))
    .pipe(minifyCss())
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./build/css'))
});

gulp.task('js', function() {
  var names = ['app'].map(function(name) { return './render/js/'+name+'.js' });
  var browserified = transform(function(filename) {
    var b = browserify(filename);
    return b.bundle();
  });
  gulp.src(names)
    .pipe(browserified)
    .pipe(uglify())
    .pipe(rename({ extname: '.min.js' }))
    .pipe(gulp.dest('./build/js'))
});

gulp.task('html', function() {
  gulp.src(['./render/*.html'])
    .pipe(escapeHTMLSnippets)
    .pipe(gulp.dest('./build/'))
});

gulp.task('build', ['css', 'js', 'html'], function() {
  gulp.src(['./fonts/**/*'])
    .pipe(gulp.dest('./build/fonts'))
  gulp.src(['./images/**/*'])
    .pipe(gulp.dest('./build/images'))
});

gulp.task('serve', function() {
  gulp.src(['./build'])
    .pipe(webserver({ port: (process.env.PORT || '8000'), open: true }))
});

gulp.task('default', ['serve'], function() {
  gulp.watch(['./*.csv'], function() {
    pictogramsData = null; // so it will reload the file
  });
  gulp.watch(['./src/**/*'], ['render']);
  gulp.watch(['./render/**/*'], ['build']);
});

gulp.task('dist', function() {
  gulp.src([
    './build/fonts/*',
    './build/css/essentials.css',
    './build/css/essentials.min.css',
    './build/css/pictograms.css',
    './build/css/pictograms.min.css'
  ]).pipe(gulp.dest('./dist'))
});
