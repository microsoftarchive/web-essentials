$package_file = Pathname.new('package.json')

def current_version
  JSON.parse($package_file.read)['version']
end

def current_version_split
  current_version.split('.').map { |i| i.to_i }
end

def save_version(new_version)
  json = JSON.parse($package_file.read)
  json['version'] = new_version.join('.')
  $package_file.open('w') { |f| f.write(JSON.pretty_generate(json)) }
  system "git add package.json"
end
