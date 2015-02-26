gem 'rake-tilde'
require 'rake/tilde'
require 'webrick/httpserver'

class NonCachingFileHandler < WEBrick::HTTPServlet::FileHandler
  def prevent_caching(res)
    res['ETag']          = nil
    res['Last-Modified'] = Time.now + 100**4
    res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
    res['Pragma']        = 'no-cache'
    res['Expires']       = Time.now - 100**4
  end

  def do_GET(req, res)
    super
    prevent_caching(res)
  end
end

def start_web_server
  Thread.new do
    s = WEBrick::HTTPServer.new Port: ENV.fetch("PORT", "8000")
    s.mount "/", NonCachingFileHandler , Dir.pwd
    trap('INT') { s.stop && exit }
    s.start
  end
end

task :default => :make

task :make do
  system "gulp make"
end

task :start => :make do
  if !$started
    $started = true
    start_web_server
  end
end
