FROM archlinux:latest

# update system
RUN pacman -Syu --noconfirm

# install dependencies
RUN pacman -S --noconfirm stow
RUN pacman -S --noconfirm fish neovim lua luarocks starship tmux ripgrep fd bat fzf zoxide eza yazi

# additional dependencies that are stripped from docker
RUN pacman -S --noconfirm openssh curl wget git

# language support
RUN pacman -S --noconfirm python npm gcc clang zig rustup

# create user and group
RUN groupadd -g 1001 patrick
RUN useradd -m -g patrick -s /bin/fish -u 1001 patrick

ADD dotfiles /home/patrick/dotfiles
RUN chown -R patrick:patrick /home/patrick

USER patrick

WORKDIR /home/patrick/dotfiles
RUN stow -t ~/ *

# create ssh folder
RUN mkdir /home/patrick/.ssh
RUN chmod 700 /home/patrick/.ssh

# setup tmux plugins (might fail if tpm was installed on the host building this)
RUN git clone https://github.com/tmux-plugins/tpm /home/patrick/.tmux/plugins/tpm | true

# install rust as user
RUN rustup default stable

WORKDIR /home/patrick
ENTRYPOINT ["/bin/fish"]

