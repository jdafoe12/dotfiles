# dotfiles

## Setup

First, install arch linux following [this guide](https://wiki.archlinux.org/title/Installation_guide) (make sure to set up a network connection!). After running `arch-chroot /mnt`, set up a boot manager:
- To use systemd-boot, `bootctl install`
- To use grub, `grub-install`

Next, install `sudo`, `zsh`, `git`, and `nano`:
    ```zsh
    pacman -S sudo zsh git nano
    ```

Create a user, add them to the `wheel` group, and set a password:
    ```zsh
    useradd -m -G wheel -s /bin/zsh username
    passwd username
    ```

Give the `wheel` group `sudo` permissions.
    ```zsh
    nano /etc/sudoers
    ```
    Uncomment the line:
    ```zsh
    %wheel ALL=(ALL:ALL) ALL
    ```

Change the default shell to `zsh`:
    ```zsh
    chsh -s /bin/zsh yourusername
    ```

Reboot the system into TTY with `reboot`.

---

Clone this repo:
```zsh 
git clone https://github.com/jdafoe12/dotfiles.git
```

Next, run the installation script:
    ```zsh
    cd dotfiles/scripts
    sudo ./install.zsh [minimal|userland|full]
    ```

    - `minimal`: Install only the packages required for dotfiles to work
    - `userland`: Install dotfiles packages plus common userland applications
    - `full`: Install everything including display manager, system services, etc.

#### Alternate keyboard layouts

To use an alternate keyboard layout:

First, you can check whether the keymap is already present:
    ```zsh
    localectl list-keymaps
    ```

If not:
1. Download the keymap file (example for Workman):
    ```zsh
    mkdir -p /usr/share/kbd/keymaps/i386/workman
    curl -o /usr/share/kbd/keymaps/i386/workman/workman.map https://raw.githubusercontent.com/workman-layout/Workman/refs/heads/master/linux_console/workman.iso15.kmap
    ```

2. Edit your keymap configuration:
    ```zsh
    nano /etc/vconsole.conf
    ```
    Add the line:
    ```
    KEYMAP=workman
    ```

Set the keyboard variant in your Hyprland config:
    ```zsh
    nano ~/dotfiles/hypr/.config/hypr/hyprland.conf
    ```
    Uncomment the line:
    ```
    kb_variant = workman
    ```
    Replace 'workman' with your layout.