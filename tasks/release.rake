def make_release

end

namespace :release do
  task :major do
    new_version = current_version_split
    new_version[0] += 1
    new_version[1] = 0
    new_version[2] = 0
    save_version new_version
    git_tag_current_version
    git_push_tags
    make_release
  end

  task :minor do
    new_version = current_version_split
    new_version[1] += 1
    new_version[2] = 0
    save_version new_version
    git_tag_current_version
    git_push_tags
    make_release
  end

  task :patch do
    new_version = current_version_split
    new_version[2] += 1
    save_version new_version
    git_tag_version
    git_push_tags
    make_release
  end
end

