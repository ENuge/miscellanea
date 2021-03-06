# Sets bash history to be unlimited, not truncated. Never lose a command!
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] 	"

# colorizes ls, but not in a way such that every extension gets a different color
alias ls="ls -G"

export EDITOR="vim"

# Current today's date to epoch time and any epoch time to a readable format
alias curr2e="date +%s"
alias e2r="date -r"

alias gpoh="git push origin HEAD"
alias darn="fuck"
function ggrep() {
  git grep -I --line-number --break --heading "$@" -- "./*" ":!*.snap" ":!*node_modules/*" ":!*.min.js*" ":!*.jpg" ":!*.png" ":!*.min.css*" ":!*common/assets*" ":!*data/*.json"
}
# mgrep means multi - intended to be combined with other greps. All it does right now is remove the --heading
# flag from the above so that I can grep -v after it more easily.
# TODO: Figure out how to keep subsequent greps nice and colorized.
function mgrep() {
  git grep -I --line-number --break "$@" -- "./*" ":!*.snap" ":!*node_modules/*" ":!*.min.js*" ":!*.jpg" ":!*.png" ":!*.min.css*" ":!*common/assets*" ":!*data/*.json"
}

alias strava="ruby ~/Documents/strava_uploader/strava.rb"

# Searches templates, actually ignores stuff in .tox and virtualenv_run
stf() {
	# TODO(eoin): This grep -v is heavyhanded, will remove code lines that mention tex and virtualenv...
	tf $1 | grep -v '.tox' | grep -v 'virtualenv*' | grep -v 'venv' | grep -v 'No such file or directory'
}

# Searches templates and Python, doesn't output grep errors.
tpf() {
	pf $1 | grep -v 'No such file or directory'
	tf $1 | grep -v 'No such file or directory'
}

# Searches JS and Python, no .tmpls, doesn't output grep errors.
jpf() {
	pf $1 | grep -v 'No such file or directory'
	tf --js-only $1 | grep -v 'No such file or directory'
}

# Git grep with line numbers, skip binary files, and show filenames
sgrep() {
	git grep -I -n -H $1 
}

# Merges a branch into the mainline for services, from: <REDACTED>
# If you supply an argument, I assume it's for a git tag that you want to push.
goym() {
	FEATURE_BRANCH=`git rev-parse --abbrev-ref HEAD`
	git fetch origin
	git checkout master
	git pull --ff-only origin master
	git merge --no-ff $FEATURE_BRANCH
	if [ -n "$1" ]; then git tag $1 && git push origin --tags HEAD; else git push origin HEAD; fi
}

fetch-deploy() {
    git fetch canon $1 && git co -b {,canon/}$1
}

subl() {
    # Strips the initial bit, /nail/home/eoin/, to get relative dir
    # Count to get what you want and replace the subl dir to where your mount is
    # Dirty and terrible but works. *shrug*
    local RELATIVE_PWD="${PWD:16}"
    ssh -p <PORT> <HOST> "source ~/.bash_profile && subl /Users/eoin/Documents/yelp/mount/$RELATIVE_PWD/$1"
}

alias scribe='scribereader -s <REDACTED>'

# lets you ask for y/n check permission before running a command
confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Runs history through a grep, slightly nicer!
alias h="history | grep "

# install fzf on ssh enter
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fuzzy open files using vim!
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fuzzy grep open based on the text on that line of the file
vg() {
  local file

  file="$(ag --nobreak --noheading $@ | fzf -0 -1 | awk -F: '{print $1 " +" $2}')"

  if [[ -n $file ]]
  then
     vim $file
  fi
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fd but only one level deep
fd1() {
  DIR=`find * -maxdepth 0 -type d -print 2> /dev/null | fzf-tmux` \
    && cd "$DIR"
}

# cdf - cd into the directory of the selected file
cdf() {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fbrr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbrr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# There's some craziness happening with bash escape codes and colors
# here and in the PS1 prompt. See http://mywiki.wooledge.org/BashFAQ/053
# for why I'm using printf and \001. Also, I needed to use
# backtick-style function calls instead of $(..) style to preserve
# the value of $? for some reason??
function nonzero_return() {
  RETVAL=$?
  if [[ "$RETVAL" != "0" ]]
  then
    printf "\001\e[91m\002>\001\e[m\002"
  else
    printf "\001\e[92m\002>\001\e[m\002"
  fi
}

# get current branch in git repo
function parse_git_branch() {
  # We need to pass along the ret val from the previous command so nonzero_return
  # can use (which executes later in our PS1 prompt). There's almost certainly
  # a nicer way of doing this, but c'est la vie.
  PREV_COMMAND_RET_VAL=$?
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
    exit $PREV_COMMAND_RET_VAL
  else
    echo ""
    exit $PREV_COMMAND_RET_VAL
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits="♻️{bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="🤕${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="💚{bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="🚀${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="🗑{bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="✌️${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

export PS1="\[\e[33m\]\w\[\e[m\]:\[\e[33m\]\u\[\e[m\]\`parse_git_branch\`\`nonzero_return\`\[\e[31m\]\\$\[\e[m\] "


# Sets bash history to be unlimited, not truncated. Never lose a command!
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] 	"
