#!/bin/bash
echo "Building site"
stack build

echo "Deliting old publication"
rm -rf _site
stack exec sitecore-weekly clean
git worktree prune
rm -rf .git/worktrees/_site/

echo "Adding worktree for master branch"
git worktree add -B master _site origin/master

echo "Generating site"
stack exec sitecore-weekly build

echo "Updating master branch"
cd _site
git add --all 
git commit -m "Publish to github"
git push origin master
