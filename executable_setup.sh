cp /etc/pacman.conf /tmp/pacman.conf.orig
cp /etc/makepkg.conf /tmp/makepkg.conf.orig


sudo sed -i 's/^[[:space:]]*#[[:space:]]*Color[[:space:]]*$/Color/' /etc/pacman.conf
sudo sed -i 's/^[[:space:]]*#[[:space:]]*VerbosePkgLists[[:space:]]*$/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i '/\[multilib\]/,/^$/s/^#//' /etc/pacman.conf
sudo sed -i '/^OPTIONS=/s/\(!debug\|debug\)/!debug/' /etc/makepkg.conf

sudo pacman -Syyu

sudo pacman -S --noconfirm --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm

cd ..

rm -rf yay-bin

yay -S --noconfirm rofi hyprland uwsm dunst waybar swww hyprpolkitagent wl-clip-persist wl-clipboard \
	nautilus gvfs \
	chromium flameshot kitty vesktop-bin github-cli btop chezmoi nwg-look grim rate-mirrors-bin \
	intel-gpu-tools intel-media-driver vulkan-intel opentabletdriver libvpl vpl-gpu-rt \
	pipewire pipewire-pulse pipewire-alsa pavucontrol \
	xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-user-dirs gnome-keyring \
	zsh zsh-autosuggestions zsh-syntax-highlighting zsh-theme-powerlevel10k-git fastfetch \
	inter-font ttf-apple-emoji noto-fonts-cjk ttf-jetbrains-mono-nerd \
	apple_cursor papirus-icon-theme libappindicator-gtk3 fcitx5-unikey fcitx5-im \
	wine-staging winetricks wine-mono wine-gecko gnutls sdl2-compat samba \
	gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg

xdg-user-dirs-update

chsh -s $(which zsh)

cat << EOF | sudo tee /etc/libinput/local-overrides.quirks > /dev/null
[disable libinput debounce]
MatchUdevType=mouse
ModelBouncingKeys=1
EOF

cat << EOF | sudo tee /etc/systemd/zram-generator.conf > /dev/null
[zram0]
zram-size = 2048
compression-algorithm = zstd
EOF

cat << EOF | sudo tee /etc/udev/rules.d/70-webhid.rules > /dev/null
SUBSYSTEM=="usb", MODE:="0660", GROUP="input", TAG+="uaccess"
SUBSYSTEM=="hidraw", MODE:="0660", GROUP="input", TAG+="uaccess"
EOF
