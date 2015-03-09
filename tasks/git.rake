def git_tag_current_version
  system "git commit -m 'Update version to #{current_version}'"
  system "git tag v#{current_version}"
end

def git_push_tags
  system "git push --tags"
end

