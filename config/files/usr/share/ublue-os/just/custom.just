!include /usr/share/ublue-os/just/bling.just

# Include some of your custom scripts here!

post-setup:
  #!/usr/bin/env bash
  flatpak --user override --filesystem=xdg-config/gtk-3.0:ro
  flatpak --user override --filesystem=xdg-config/gtk-4.0:ro
  flatpak --user override --filesystem=xdg-data/themes:ro
  flatpak --user override --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox
  flatpak --user override --env=MOZ_DBUS_REMOTE=1
  flatpak --user override --env=FLATPAK_ENABLE_SDK_EXT=* com.visualstudio.code
  flatpak --user override --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
  flatpak --user override --filesystem=~/.var/app/com.valvesoftware.Steam/data/Steam com.usebottles.bottles
  rpm-ostree kargs --append-if-missing=amdgpu.ppfeaturemask=0xffffffff --append-if-missing=drm.edid_firmware=DP-3:edid/aoc-edid.bin --append-if-missing=video=DP-3:e --append-if-missing=amdgpu.gpu_recovery=1 --append-if-missing=rd.luks.options=fido2-device=auto
  rpm-ostree initramfs --enable --arg=-I --arg=/lib/firmware/edid/aoc-edid.bin --arg=--add --arg=fido2
  pkexec usermod -a -G gamemode "$USER"
  systemctl enable --now ratbagd.service
  mkdir -p ~/.local/bin
  cp /usr/etc/my-ublue/podman-host ~/.local/bin/podman-host
  chmod +x ~/.local/bin/podman-host
  mkdir -p ~/.config/MangoHud
  cp /usr/etc/my-ublue/MangoHud.conf ~/.config/MangoHud