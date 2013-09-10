# git-perm-rm

Permanently remove a file or directory from a git repo.

## Usage

### Remove directories

```sh
# bash
cd /your/repo
git-perm-rm node_modules temp -r
```
### Remove file(s)

```
cd /your/repo
git-perm-rm index.js
```

## Installation

Edit your `~/.bashrc` file, add the following code

```sh
alias="bash /your/repo/git-perm-rm.sh"
```