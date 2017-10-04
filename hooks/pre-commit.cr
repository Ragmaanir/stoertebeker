#!/usr/bin/env crystal

system("./build")

if /README\.md\.template/ === `git diff --staged --name-status README.md.template`
  unstaged = /README\.md[^\.]/ === `git diff --name-status README.md`
  not_staged = !(/README\.md[^\.]/.match(`git diff --staged --name-status README.md`))
  abort("The README changed, please add it") if unstaged || not_staged
  # abort("build.cr failed") if !system("./build")
  # abort("git add README.md failed") if !system("git", ["add", "README.md"])
end
