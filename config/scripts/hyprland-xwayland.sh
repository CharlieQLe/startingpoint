#!/usr/bin/env bash

set -oue pipefail

wget "https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-${OS_VERSION}/solopasha-hyprland-fedora-${OS_VERSION}.repo" -P "/etc/yum.repos.d/"

rpm-ostree override replace xorg-x11-server-Xwayland --experimental --from repo='copr:copr.fedorainfracloud.org:solopasha:hyprland'