# vim: set ft=dockerfile:
FROM archlinux/base

RUN \
    pacman -Sy --noprogressbar --noconfirm \
 && pacman -S --noprogressbar --noconfirm sed \
 && curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=6&use_mirror_status=on" \
 && sed -i 's/^#//' /etc/pacman.d/mirrorlist \
 && pacman -Sy --noprogressbar --noconfirm archlinux-keyring \
 && pacman -S --noprogressbar --noconfirm --force openssl \
 && pacman -S --noprogressbar --noconfirm pacman \
 && pacman-db-upgrade \
 && echo "[multilib]" >> /etc/pacman.conf \
 && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
 && pacman -Syyu --noprogressbar --noconfirm

RUN \
    pacman -S --noprogressbar --noconfirm \
            base-devel \
            bat \
            exa \
            fd \
            git \
            openssh \
            httpie \
            rustup \
            python \
            python-pip \
            ripgrep \
            tmux \
            vim \
            wget \
            zsh \
 && rustup default stable

# Add a user and install dotfiles
RUN \
    groupadd sudo \
 && echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers \
 && useradd --create-home john -G sudo \
 && echo "john:rootpw" | chpasswd \
 && chsh -s $(which zsh) john \
 && cd /home/john \
 && git clone https://github.com/scizzorz/dots.git \
 && chown -R john:john dots \
 && cd dots \
 && su john -c './install.sh' \
 && cd .. \
 && mkdir .ssh \
 && chown john:john .ssh \
 && chmod 700 .ssh

VOLUME /home/john/dev
WORKDIR /home/john
USER john
CMD ["/usr/bin/zsh"]
