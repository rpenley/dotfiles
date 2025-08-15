# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=20000
SAVEHIST=20000
setopt EXTENDED_HISTORY         # Save command timestamp
setopt HIST_EXPIRE_DUPS_FIRST   # Remove duplicates first
setopt HIST_IGNORE_DUPS         # Don't store duplications
setopt HIST_FIND_NO_DUPS        # Ignore duplicates when searching
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks
setopt HIST_VERIFY              # Verify command when using history

# Directory navigation
setopt AUTO_CD                  # Type directory name to cd
setopt AUTO_PUSHD               # Push directory onto stack automatically
setopt PUSHD_IGNORE_DUPS        # Ignore duplicates in the directory stack
setopt PUSHDMINUS               # Make `cd -` work
setopt EXTENDED_GLOB            # Extended globbing capabilities
setopt PROMPT_SUBST             # Allow variable substitution in prompt

# Global completion behavior
setopt GLOB_COMPLETE            # Show completions for globs
setopt AUTO_LIST                # Automatically list choices on ambiguous completion
setopt COMPLETE_IN_WORD         # Complete from both ends of a word
setopt ALWAYS_TO_END            # Move cursor to end of word when completing

# No beep
unsetopt BEEP

# get brew location
BREW_PREFIX=$(brew --prefix)

# Homebrew Config
PATH="$BREW_PREFIX/opt/llvm/bin:$PATH"
PATH="$BREW_PREFIX/opt/curl/bin:$PATH"
PATH="$BREW_PREFIX/opt/gcc/bin:$PATH"
PATH="$BREW_PREFIX/bin:$PATH"


# Define LS_COLORS for highlighting
if type vivid &>/dev/null; then
	export LS_COLORS=$(vivid generate gruvbox-dark)
else 
	export LS_COLORS="di=1;34:ln=1;36:so=1;31:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
fi

# Make Homebrew's completions available
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  
  # Ensure compinit is called after FPATH is modified
  autoload -Uz compinit
  compinit
fi

# Syntax highlighting
if [[ -f $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Auto-suggestions 
if [[ -f $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Completion configuration
zstyle ':completion:*' cache-path $HOME/.zsh/cache        # Specify cache location
#zstyle ':completion:*' group-name ''                      # Group matches by category
#zstyle ':completion:*' insert-tab false
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion
#zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive completion
zstyle ':completion:*' menu select                        # Use menu selection for completion
zstyle ':completion:*' special-dirs true                  # Include . and .. in completion
zstyle ':completion:*' use-cache on                       # Cache completion
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches found%f'

# Configure completion to cycle through options with tab
#bindkey '^I' autosuggest-accept

#ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

# FZF key bindings and completion if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Rust packages if cargo exists
[ -f ~/.cargo/env ] && source ~/.cargo/env

# Use GNU Utilities
alias sed='gsed'
alias tar='gtar'
alias awk='gawk'
alias make='gmake'

# directory listings with exa
if (( $+commands[eza] )); then
	alias ls='eza'
	alias ll='eza -la'
	alias lt='eza -T --git-ignore'
fi

# find with fd or gnu find
if (( $+commands[fd] )); then
	alias find='fd'
	FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif (( $+commands[gfind] )); then
	alias find='gfind'
fi

# grep with ripgrep or gnu grep
if (( $+commands[rg] )); then
	alias grep='rg'
elif (( $+commands[ggrep] )); then
	alias grep='ggrep'
fi

# cat with bat
if (( $+commands[bat] )); then
	alias cat='bat --style=plain --paging=never'  # act like cat
	alias ccat='bat'
fi

# Better git diff with delta
if (( $+commands[delta] )); then
	# This doesn't replace git diff directly, but sets up git to use delta
	git config --global core.pager "delta"
	git config --global interactive.diffFilter "delta --color-only"
	git config --global delta.navigate true
	git config --global delta.light false  # Use dark mode
fi

# Configure Compiler Flags
LLVM_HOME="$BREW_PREFIX/opt/llvm"
LDFLAGS="-L$LLVM_HOME/lib -Wl,-rpath,$LLVM_HOME/lib,$BREW_PREFIX/opt/sdl3/lib"
CFLAGS="-I$LLVM_HOME/include -I$BREW_PREFIX/opt/sdl3/include"
CPPFLAGS=$CFLAGS
CC="$LLVM_HOME/bin/clang"
CXX="$LLVM_HOME/bin/clang++"

export CPATH="$(brew --prefix sdl3)/include:$CPATH"
export LIBRARY_PATH="$(brew --prefix sdl3)/lib:$LIBRARY_PATH"
export PKG_CONFIG_PATH="$(brew --prefix sdl3)/lib/pkgconfig:$PKG_CONFIG_PATH"

eval "$(starship init zsh)"

