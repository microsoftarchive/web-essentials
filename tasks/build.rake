require 'net/http'
require 'json'

# utility functions to convert path names
def src_to_build(stuff)
  stuff.pathmap('%{^src,build}p')
end

def src_to_render(stuff)
  stuff.pathmap('%{^src,render}p')
end

def dot_to_build(stuff)
  stuff.pathmap("build/%p")
end

lib_css_files        = src_to_render FileList["src/css/lib/*.css"] # css files depend on the files in lib
intended_css_files   = src_to_build  FileList["src/css/*.css"].ext('.min.css')
intended_js_files    = src_to_build  FileList["src/js/*.js"].ext('.min.js')
intended_html_files  = src_to_build  FileList["src/*.html"]
intended_font_files  = dot_to_build  FileList["fonts/*"]
intended_image_files = dot_to_build  FileList["images/**/*.*"]

CLEAN.include("build/**/*") # rake clean will remove all these files

# these procs are to be used for the file rule source matchers so all files
# depend on the related file in render/

css_build_to_render = ->(name){ name.pathmap('%{^build/,render/}p').ext.ext('css') }
js_build_to_render = ->(name){ name.pathmap('%{^build/,render/}p').ext.ext('js') }
build_to_render = ->(name){ name.pathmap('%{^build/,render/}p') }
build_to_dot    = ->(name){ name.pathmap('%{^build/,}p') }



# These rules will depend on a file in render/ which will in turn look for the
# rules from render.rake

rule %r{^build/css/.*\.min\.css$} => [css_build_to_render, *lib_css_files] do |t|
  FileUtils.mkdir_p File.dirname(t.name)
  sh "basswork #{t.source} | cleancss > #{t.name}"
end

rule %r{^build/js/.*\.min\.js$} => [js_build_to_render] do |t|
  FileUtils.mkdir_p File.dirname(t.name)
  sh "browserify -g uglifyify #{t.source} > #{t.name}"
end

rule %r{^build/.*\.html$} => [build_to_render] do |t|
  File.dirname(t.name).tap do |dir|
    mkdir_p dir
    cp t.source, dir
  end
end

rule %r{^build/(fonts/|images/)} => [build_to_dot] do |t|
  File.dirname(t.name).tap do |dir|
    mkdir_p dir
    cp t.source, dir
  end
end


def build_url(path)
  root_dir = File.expand_path '../..', __FILE__
  root_regex = Regexp.new("^#{root_dir}")
  relative_path = path.gsub(root_regex, '')

  case relative_path
  when %r{^/images/}
    relative_path
  when %r{^/src/}
    relative_path.gsub(%r{^/src/}, '/')
  end
end


$livereload_uri = URI("http://localhost:35729/changed")

task :build => ["build:css", "build:js", "build:html", "build:fonts", "build:images"]
listen to: :build, paths: %w(src/ images/ fonts/) do |modified, added, removed|
  livereload_files = [modified, added, removed].flatten.map { |u| build_url(u) }.compact
  puts "Live reloading: #{livereload_files.join(", ")}"

  req = Net::HTTP::Post.new $livereload_uri
  req.body = JSON.generate(files: livereload_files)
  req.content_type = 'application/json'

  begin
    Net::HTTP.start($livereload_uri.host, $livereload_uri.port) { |http| http.request req }
  rescue
    puts "Updating livereload failed... Not sure why."
  end
end

namespace :build do
  task :css => intended_css_files
  task :js => intended_js_files
  task :html => intended_html_files
  task :fonts => intended_font_files
  task :images => intended_image_files
end
