set fish_greeting

abbr -a e nvim
abbr -a g git
abbr -a gah 'git stash; and git pull --rebase; and git stash pop'

if status is-interactive
    # Commands to run in interactive sessions can go here
end
fish_add_path $GOPATH/bin

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/alexandreschoenwitz/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
