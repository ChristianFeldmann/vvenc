#!/usr/bin/env bash

release_version=$1

# Start Release
git fetch --progress --prune --recurse-submodules=no origin refs/heads/develop:refs/remotes/origin/develop
git branch --no-track release/${release_version} refs/heads/develop
git checkout release/${release_version}

# Finish Release
git fetch --progress --prune --recurse-submodules=no origin refs/heads/main:refs/remotes/origin/main
git fetch --progress --prune --recurse-submodules=no origin refs/heads/develop:refs/remotes/origin/develop
git fetch --tags origin
git checkout --ignore-other-worktrees main
git merge --no-ff -m "Finish ${release_version}" release/${release_version}
git tag -a ${release_version} -m "Finish ${release_version}" refs/heads/main
git checkout develop
git branch -D release/${release_version}

git push --porcelain --progress --recurse-submodules=check origin refs/heads/main:refs/heads/main \
                                                                  refs/heads/develop:refs/heads/develop \
                                                                  refs/tags/${release_version}:refs/tags/${release_version}

# Merge main into develop
git merge --no-ff -m "Finish ${release_version}" origin/main

# Push develop
git push --porcelain --progress --recurse-submodules=check origin refs/heads/develop:refs/heads/develop
