require 'rack/contrib/try_static'
require 'rack/livereload'

$app = Rack::Builder.new {
  use Rack::LiveReload, no_swf: true

  use Rack::TryStatic,
    root: './build',
    urls: %w[/],
    try: ['.html', 'index.html', '/index.html']

  run ->(env) {
    four_oh_four_page = File.new("./build/404.html")
    [404, { 'Content-Type'  => 'text/html'}, four_oh_four_page.each_line]
  }
}

task :serve => ['serve:http', 'serve:websockets', 'tilde:sleep']

namespace :serve do

  task :websockets do
    puts "booting the livereload server"

    pid = spawn('tiny-lr')
    $live_reload = true # for later

    at_exit do
      puts "killing the livereload server"
      Process.kill 9, pid
      Process.wait pid
      sleep 0.1
    end
  end

  task :http do
    puts "booting the files server"

    port = ENV.fetch("PORT", 8000)
    nowait = !!ENV["NOWAIT"]

    pid = fork do
      begin
        Rack::Server.start({
          app:         $app,
          environment: :development,
          server:      :webrick,
          Port:        port
        })
      rescue
        puts "an error happened in the fork"
        raise
      end
    end

    Thread.new do
      sleep 3
      puts "*** Server is running: http://localhost:#{port}/"
      `open http://localhost:#{port}/`
    end

    at_exit do
      puts "killing the files server"
      Process.kill 9, pid
      Process.wait pid
      sleep 0.1
    end
  end

end
