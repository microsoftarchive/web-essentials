dist_files   = FileList['src/css/*.css'].pathmap('%{^src/css/,dist/}p').ext('.min.css')
dist_files.add FileList['fonts/*'].pathmap('%{^fonts/,dist/}p')

proc_for_dist = ->(name) do
  if File.extname(name) == "css"
    name.pathmap('%{^dist/,build/css/}p').ext.ext('.css')
  else
    # must be a font
    name.pathmap('%{^dist/,build/fonts}p')
  end
end



rule %r{^dist/} => [proc_for_dist] do |t|
  File.dirname(t.name).tap do |dir|
    mkdir_p dir
    cp t.source, dir
  end
end



task :dist => dist_files
