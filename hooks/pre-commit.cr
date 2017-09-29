#!/usr/bin/env crystal

if /README\.md\.template/ === `git diff --staged --name-status README.md.template`
  abort("Run ./build to update README and git add it") if /README\.md[^\.]/ === `git diff --name-status README.md`
  # abort("build.cr failed") if !system("./build")
  # abort("git add README.md failed") if !system("git", ["add", "README.md"])
end
