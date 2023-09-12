#!/usr/bin/env bash

set -oue pipefail

rpm-ostree override replace xorg-x11-server-Xwayland --experimental --from repo='copr:copr.fedorainfracloud.org:solopasha:hyprland'