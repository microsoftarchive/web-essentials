require 'bundler'
begin
  Bundler.require
rescue Bundler::GemNotFound
  $stderr.puts "You need to bundle install"
  exit 1
end
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
