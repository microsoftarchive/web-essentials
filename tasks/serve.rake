require 'rack/contrib/try_static'

$app = ->(env) {
  use Rack::TryStatic,
    root: './build',
    urls: %w[/],
    try: ['.html', 'index.html', '/index.html']

  run ->(env) {
    four_oh_four_page = File.new("./build/404.html")
    [404, { 'Content-Type'  => 'text/html'}, four_oh_four_page.lines]
  }
}

task :serve do
  pid = fork do
    Rack::Server.start({
      app:         $app,
      environment: :development,
      server:      :puma
    })
  end

  begin
    Process.wait pid
  rescue Interrupt
    # noop
  end

  at_exit do
    Process.kill "TERM", pid
    Process.wait pid
  end
end
