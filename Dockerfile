FROM archlinux:latest

# update system
RUN pacman -Syu --noconfirm

# install dependencies
RUN pacman -S --noconfirm stow
RUN pacman -S --noconfirm fish neovim lua luarocks starship tmux ripgrep fd bat fzf zoxide eza yazi

# additional dependencies that are stripped from docker
RUN pacman -S --noconfirm openssh curl wget git

# language support
RUN pacman -S --noconfirm python npm gcc clang zig rustup go

# create user and group
RUN groupadd -g 1001 ko1N
RUN useradd -m -g ko1N -s /bin/fish -u 1001 ko1N

ADD dotfiles /home/ko1N/dotfiles
RUN chown -R ko1N:ko1N /home/ko1N

USER ko1N

WORKDIR /home/ko1N/dotfiles
RUN stow -t ~/ *

# create ssh folder
RUN mkdir /home/ko1N/.ssh
RUN chmod 700 /home/ko1N/.ssh

# setup tmux plugins (might fail if tpm was installed on the host building this)
RUN git clone https://github.com/tmux-plugins/tpm /home/ko1N/.tmux/plugins/tpm | true

# install rust as user
RUN rustup default stable

WORKDIR /home/ko1N
ENTRYPOINT ["/bin/fish"]

