[alias]
  # Macro 'up' moved to ~aalexandre/bin/git-up

  # What is the master branch? Some use "master", some use "trunk"
  main-branch = !sh -c "'\
if git is-branch master; then echo master; \
elif git is-branch trunk; then echo trunk; \
else echo Cannot find a branch called master or trunk. >&2; \
fi; \
'"

  # Automatically stashes current changes and works on another branch
  work-on = !sh -c "'\
if [ \"$0\" = sh ]; then \
  echo Usage: git work-on branchname; \
  exit 1; \
fi; \
if [ \"$0\" = \"$(git what-branch)\" ]; then \
  echo \"# Yup, working on $0.\"; \
  exit 0; \
fi; \
git push-autostash && \
git ensure-branch \"$0\" && \
git pop-autostash \
'"

  # Pushes current commit into the repository and upon success deletes
  # current branch and sets current branch to master.
  arc-commit = !sh -c "'\
if [ $0 = \"--revision\" ]; then \
  REVISION=\"--revision $1\"; \
fi; \
THISBRANCH=$(git what-branch) && \
/home/engshare/devtools/arcanist/bin/arc amend $REVISION && \
git checkout $(git main-branch) && \
git cherry-pick -- $THISBRANCH && \
git pull --rebase && \
git push && \
git branch -D $THISBRANCH \
'"

  # Commits changes and submits initial diff for review
  arc-diff = !git commit -a && /home/engshare/devtools/arcanist/bin/arc diff

  # Commits changes and submits subsequent diff for review
  arc-rediff = !git commit -a --amend && /home/engshare/devtools/arcanist/bin/arc diff

  # Abandons the current branch entirely
  abandon-this-branch = "!\
THISBRANCH=$(git what-branch) && \
git stash save abandoned-$THISBRANCH && \
git reset --hard HEAD && \
git checkout $(git main-branch) && \
git branch -D $THISBRANCH \
"

  # Abandons the specified branch entirely
  abandon-branch = !sh -c "'\
if [ \"$0\" = sh ]; then \
  echo Usage: git abandon-branch branchname; \
  exit 1; \
fi; \
THISBRANCH=$(git what-branch); \
if [ \"$0\" = \"$THISBRANCH\" ]; then \
  git abandon-this-branch; \
else \
  git is-branch $0 && \
  git work-on $0 && \
  git abandon-this-branch && \
  git work-on $THISBRANCH; \
fi \
'"

  # Shows the formerly abandoned branches along with instructions on
  # how to revive them.
  fml = "!\
if git stash list --date=default | grep -q -m 1 -s ': abandoned-'; then \
  echo \"# Take a look at your abandoned branches below.\" \
    \"To revive a branch, use 'git stash branch <branchname> stash@{nnn}'\" && \
  git stash list --date=default | grep ': abandoned-'; \
fi \
"

# The following macros are helpers for higher level artifacts, but can
# also be used individually

  # Prints current branch, with optional prefix and suffix, and returns 0.
  # If not on a branch, prints nothing and returns nonzero.
  # Example (assuming you're on branch 'br'):
  # git what-branch -> prints br
  # git what-branch '(' ')' -> prints (br)
  # The affixes are useful if e.g. you want to use this inside your prompt.
  what-branch = "!sh -c '\
if [ $0 = sh ]; then P0=\"\"; else P0=$0; fi; \
WHATBRANCH=$(git rev-parse --abbrev-ref HEAD); \
[ \"$WHATBRANCH\" != \"(no branch)\" ] || WHATBRANCH=\"\"; \
[ ! -z \"$WHATBRANCH\" ] && echo \"$P0$WHATBRANCH$1\" \
'"

  # Is this a branch? Yields 0 if so, nonzero otherwise. Example: git
  # is-branch foo yields 0 if foo is the name of a branch, 1 if not.
  is-branch = !sh -c "'\
if [ \"$0\" = sh ]; then \
  echo Usage: git is-branch somename; \
  exit 1; \
fi; \
git branch --no-color 2>/dev/null | grep -q \"$0\" \
'"

  # If the branch exists, checks it out. Otherwise, creates it as a
  # new branch of master.
  ensure-branch = !sh -c "'\
if [ \"$0\" = sh ]; then P0=\"\"; else P0=\"$0\"; fi; \
if git is-branch \"$P0\"; then \
  git checkout \"$P0\"; \
else \
  git checkout -b \"$P0\" $(git main-branch); \
fi \
'"

  # Stashes current branch with a specific cookie
  push-autostash = !git stash save autostash-$(git what-branch)

  # If push-autostash cookie present, pops that. WARNING if you have
  # some default date set, that may influence the way "git stash list"
  # displays things, which breaks this script. This is an issue with
  # git, see http://goo.gl/ZHPyX and http://goo.gl/Eftm7
  pop-autostash = "!\
INDEX=$(git stash list --format=\"%gd: %gs\" | \
            grep autostash-$(git what-branch) | head -n1 \
            | sed 's/^\\(stash@{[0-9][0-9]*}\\).*/\\1/'); \
if [ -z \"$INDEX\" ]; then \
   echo 'Nothing to pop-autostash'; \
else \
   git stash pop \"$INDEX\"; \
fi \
"

# Creates a snapshot of the code, see http://blog.apiaxle.com/post/handy-git-tips-to-stop-you-getting-fired/

snapshot = !git stash save "snapshot@$(date +'%Y/%m/%d-%H:%M:%S')" && git stash apply "stash@{0}"

# Common shortcuts
  co = checkout
  ci = commit
  st = status
  newbr = checkout -b
  killbr = branch -D
  delbr = branch -d
  br = branch
  unstage = reset HEAD

[user]
	name = Javier Sierra
	email = javess@fb.com
[core]
	editor = emacs

[log]
  date = relative
