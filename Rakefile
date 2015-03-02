require 'json'

Bundler.setup

$package_file = Pathname.new("./package.json")

def current_version
  JSON.parse($package_file.read)["version"]
end

def current_version=(new_version)
  json = JSON.parse($package_file.read)
  json["version"] = new_version
  $package_file.write(json, "w")
end

task :env do
  require "dotenv"
  Dotenv.overload
end

namespace :release do
  task :major do

  end

  task :minor do

  end

  task :patch do

  end
end

namespace :s3 do
  task :setup => :env do
    require "aws-sdk"
    require "mime-types"

    ENV.fetch("AWS_ACCESS_KEY_ID")
    ENV.fetch("AWS_SECRET_ACCESS_KEY")

    $s3 = Aws::S3::Resource.new
  end

  desc "update the bucket policy and website settings correctly"
  task :update_bucket => :setup do
    bucket = $s3.bucket(ENV.fetch("S3_BUCKET_NAME"))

    policy = <<-EOF.strip
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::#{ENV.fetch("S3_BUCKET_NAME")}/*"
          }
        ]
      }
    EOF

    config = {
      index_document: {
        suffix: "index.html"
      }
    }

    bucket.policy.put(policy: policy)
    bucket.website.put(website_configuration: config)
  end

  desc "upload to s3"
  task :upload => [:setup, :compile] do
    bucket = $s3.bucket(ENV.fetch("S3_BUCKET_NAME"))

    files = FileList["dist/*"]
    files.each do |file|
      file = File.basename(file)
      mime = MIME::Types.of(file).first.to_s
      bucket.object(file).put(content_type: mime, acl: "public-read", body: File.new(file))
    end
  end
end
