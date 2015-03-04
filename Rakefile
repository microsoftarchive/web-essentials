begin
  require 'bundler'
  begin
    Bundler.require
  rescue Bundler::GemNotFound
    $stderr.puts "You need to bundle install"
    exit 1
  end
rescue LoadError
  if ARGV == ["clean"]
    require 'rake/clean'
    CLEAN.include('render/**/*')
    CLEAN.include('build/**/*')
    no_bundler = true
  else
    puts "You need to run: make install"
    exit 1
  end
end

unless no_bundler
  require 'json'
  require 'csv'
  require 'rake/clean'

  Dotenv.overload

  $src_files = FileList["src/**/*.*"]

  load 'tasks/package.rake'
  load 'tasks/git.rake'
  load 'tasks/render.rake'
  load 'tasks/build.rake'
  load 'tasks/serve.rake'
  load 'tasks/dist.rake'
  load 'tasks/release.rake'
end
