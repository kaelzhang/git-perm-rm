# git-perm-rm

Permanently remove a file or directory from a git repo including all related commit records.

It's a very usefull script to get your git repo more sexy and slim, but at the meantime, it is dangerous and irreversible !

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

## Install

Install with npm

```sh
npm install -g git-perm-rm
```

Or, clone the repo, edit your `~/.bashrc` file, add the following code:

```sh
alias="bash /your/repo/git-perm-rm.sh"
```