# history
HISTSIZE=20000
SAVEHIST=20000

# no beep
unsetopt BEEP

# get brew location
BREW_PREFIX=$(brew --prefix)

# Homebrew Config
PATH="$BREW_PREFIX/opt/llvm/bin:$PATH"
PATH="$BREW_PREFIX/opt/curl/bin:$PATH"
PATH="$BREW_PREFIX/opt/gcc/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="$BREW_PREFIX/bin:$PATH"

# Use GNU Utilities
alias find='gfind'
alias sed='gsed'
alias tar='gtar'
alias grep='ggrep'
alias awk='gawk'
alias make='gmake'

# Configure Compiler Flags
LLVM_HOME="$BREW_PREFIX/opt/llvm"
LDFLAGS="-L$LLVM_HOME/lib -Wl,-rpath,$LLVM_HOME/lib"
CPPFLAGS="-I$LLVM_HOME/include"
CC="$LLVM_HOME/bin/clang"
CXX="$LLVM_HOME/bin/clang++"

# source "$HOME/.cargo/env"

eval "$(starship init zsh)"
