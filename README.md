# dotfiles

## Setup

First, install Arch Linux following [this guide](https://wiki.archlinux.org/title/Installation_guide) (**make sure to set up a network connection!**)

After running `arch-chroot /mnt`, set up a boot manager:
- To use systemd-boot:
  ```sh
  bootctl install
  ```
- To use grub:
  ```sh
  grub-install
  ```

Next, install `sudo`, `zsh`, `git`, and `nano`:
```sh
pacman -S sudo zsh git nano
```

Create a user, add them to the `wheel` group, and set a password:
```sh
useradd -m -G wheel -s /bin/zsh yourusername
passwd yourusername
```

Give the `wheel` group `sudo` permissions:
```sh
EDITOR=nano visudo
```
Uncomment the line:
```
%wheel ALL=(ALL:ALL) ALL
```

Change the default shell to `zsh`:
```sh
chsh -s /bin/zsh yourusername
```

Reboot the system into TTY:
```sh
reboot
```

---

## Clone and Install

Clone this repo:
```sh
git clone https://github.com/jdafoe12/dotfiles.git
```

Run the installation script:
```sh
cd dotfiles/scripts
sudo ./install.zsh [minimal|userland|full]
```

- `minimal`: Install only the packages required for dotfiles to work
- `userland`: Install dotfiles packages plus common userland applications
- `full`: Install everything including display manager, system services, etc.

---

## Alternate Keyboard Layouts

To use an alternate keyboard layout:

1. **Check if the keymap is already present:**
   ```sh
   localectl list-keymaps
   ```

2. **If not, download the keymap file (example for Workman):**
   ```sh
   sudo mkdir -p /usr/share/kbd/keymaps/i386/workman
   sudo curl -o /usr/share/kbd/keymaps/i386/workman/workman.map \
     https://raw.githubusercontent.com/workman-layout/Workman/refs/heads/master/linux_console/workman.iso15.kmap
   ```

3. **Edit your keymap configuration:**
   ```sh
   sudo nano /etc/vconsole.conf
   ```
   Add the line:
   ```
   KEYMAP=workman
   ```

4. **Set the keyboard variant in your Hyprland config:**
   ```sh
   nano ~/dotfiles/hypr/.config/hypr/hyprland.conf
   ```
   Uncomment the line:
   ```
   kb_variant = workman
   ```
   Replace `workman` with your layout if needed.