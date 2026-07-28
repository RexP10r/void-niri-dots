ZSH_THEME="robbyrussell"

export PATH="$HOME/.cargo/bin:$PATH"
export LIBVIRT_DEFAULT_URI="qemu:///system"
source $HOME/.config/zsh/config.zsh

# cuda
export PATH="$PATH:/usr/local/cuda/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"

plugins=(git)

# lazyff
export PATH="/home/rexp10r/.lazyff/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
