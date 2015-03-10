require 'tempfile'
require 'zlib'

MIME::Types.add(MIME::Types['application/font-woff'].first.tap {|m| m.add_extensions('woff2')})

def url(file)
  name = File.basename(file)
  "https://d1l1r288vf46ed.cloudfront.net/v#{current_version}/#{name}"
end

namespace :release do
  task :major => [:major_increase, :make]
  task :minor => [:minor_increase, :make]
  task :patch => [:patch_increase, :make]

  task :font_cdn do
    $font_host = "https://d1l1r288vf46ed.cloudfront.net/#{current_version}"
  end

  task :make => [:font_cdn, :clean, :render] do
    client = Aws::S3::Client.new(region: 'eu-west-1')

    $dist_files.each do |file|
      puts "published: #{url(file)}"
      key = "v#{current_version}/#{File.basename(file)}"
      obj = Aws::S3::Object.new('web-styleguide-assets', key, client: client)
      mime = MIME::Types.of(file).first.content_type
      tempfile = Tempfile.new 'foo'
      gz = Zlib::GzipWriter.new tempfile
      begin
        gz.write File.read(file)
        gz.flush
        tempfile.rewind

        obj.put({
          body: tempfile.read,
          acl: "public-read",
          content_type: mime,
          cache_control: 'max-age=315360000',
          content_encoding: 'gzip'
        })
      ensure
        gz.close
        tempfile.unlink
      end
    end
  end

  task :major_increase do
    new_version = current_version_split
    new_version[0] += 1
    new_version[1] = 0
    new_version[2] = 0
    save_version new_version
    git_tag_current_version
    git_push_tags
  end

  task :minor_increase do
    new_version = current_version_split
    new_version[1] += 1
    new_version[2] = 0
    save_version new_version
    git_tag_current_version
    git_push_tags
  end

  task :patch_increase do
    new_version = current_version_split
    new_version[2] += 1
    save_version new_version
    git_tag_current_version
    git_push_tags
  end
end

