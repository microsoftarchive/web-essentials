require 'erb'
require 'json'

$font_host ||= "/fonts"

module JSONReader
  module_function
  def read(filename)
    JSON.parse File.read(filename)
  end
end

class Context
  attr_accessor :output
  attr_reader :locals

  def self.render(filename)
    new.render(filename)
  end

  def initialize(locals = {})
    @locals = locals
    @output = ""
  end

  def locals
    @locals ||= {}
  end

  def method_missing(name, *args, &blk)
    if locals.key?(name)
      value = locals[name]
      if value.respond_to?(:call)
        value.call
      else
        value
      end
    else
      super
    end
  end

  def b
    binding
  end

  def render(filename, opts = {})
    context = self.class.new opts
    filename = File.expand_path filename, Thread.current[:render_dir]
    contents = File.read(filename)
    original_render_dir = Thread.current[:render_dir]
    Thread.current[:render_dir] = File.dirname(filename)
    e = ERB.new(contents, nil, nil, "@output")
    e.filename = filename
    puts "render: #{filename}"
    e.result(context.b)
    Thread.current[:render_dir] = original_render_dir
    context.output
  rescue Errno::ENOENT
    $stderr.puts "!!! Could not find file #{filename}"
    %Q{<p class="red">Error: missing file '#{filename}'</p>}
  rescue StandardError => exception
    $stderr.puts "!!! Exception when requiring file #{filename}"
    $stderr.puts exception.message
    $stderr.puts exception.backtrace.join("\n")
    %Q{<p class="red">Error loading file: #{filename}</p>}
  end

  def code(**opts, &blk)
    html = capture(&blk)
    result = "<pre><code>#{ERB::Util.h(html).strip}</code></pre>"
    result = "#{html}#{result}" if opts[:insert]
    @output << result
  end

  def capture(*args, &blk)
    pos = @output.length
    blk.call(*args)
    data = @output[pos..-1]
    @output[pos..-1] = ''
    data
  end
end

module Kernel
  def render(filename)
    Context.render filename
  end
end



data_files            = FileList['pictograms.csv'] # all the data files to load
intended_render_files = $src_files.exclude(%r{src/.*/.*\.html}).pathmap('%{^src/,render/}p') # we want each file in source to also end up in render under the same name

CLEAN.include("render/**/*") # rake clean will remove all these files

data_readers = Hash.new { |k, h| File }
data_readers["csv"] = CSV
data_readers["json"] = JSONReader


=begin
A rule conveys three things:

1. An intended file (or file pattern) as a task, using the file's name
2. Another file (or transformation) this file depends on
3. How to create the intended file

An example:

rule "readme.html" => ["readme.markdown"] do
  t.source # => "readme.markdown"
  t.name   # => "readme.html"
  sh "markdown #{t.source}"
end

Rake is smart enough to know when the source file has changed and only rebuild
either missing files or files who's sources have changed. It's possible for an
intended file to depend on multiples sources (in which case one would have
`t.sources`), hence the array.
=end

# make a lambda that can convert a filepath from render to src
render_to_src = ->(name) {
  src_name = name.pathmap('%{^render/,src/}p')
  [src_name, FileList["#{name.pathmap('%X')}/*.*"]].flatten
}

# any file expected to be in ./render depends on the file with the same name in ./src
# we create any missing file in ./render by reading and rendering the related file in ./src
rule %r{^render/} => [render_to_src] do |t|
  mkdir_p File.dirname(t.name)
  File.open(t.name, "w") { |f| f << render(t.source) }
  puts "write: #{t.name}"
end

# TODO: html file at the base should depend on the html files in a folder with the same name

task :render => ["render:default"]

namespace :render do
  # depends on all data files
  task :data => data_files do |t|
    $data = t.sources.each_with_object({}) do |file, memo|
      name = file.pathmap('%n').to_sym # pictograms.csv => :pictograms
      puts "parsing: #{file}"
      memo[name] = data_readers[File.extname(file)[1..-1]].read(file)
    end
  end

  task :default => intended_render_files # depends on all expected files to be in ./render, which trigger to above rule to auto-create tasks for them

  intended_render_files.each { |n| file n => :data } # make sure none of the files can be rendered until after we've loaded the data
end
