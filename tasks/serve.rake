require 'rack/contrib/try_static'

$app = Rack::Builder.new {
  use Rack::TryStatic,
    root: './build',
    urls: %w[/],
    try: ['.html', 'index.html', '/index.html']

  run ->(env) {
    four_oh_four_page = File.new("./build/404.html")
    [404, { 'Content-Type'  => 'text/html'}, four_oh_four_page.each_line]
  }
}

task :serve do
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

  # `open http://localhost:#{port}/`

  unless nowait
    begin
      Process.wait pid
    rescue Interrupt
      # noop
    end
  end

  at_exit do
    begin
      sleep
    rescue Interrupt
      puts "killing the server"
      Process.kill 9, pid
      Process.wait pid
      puts "hit ^C one more time"
      puts
    end
  end
end
