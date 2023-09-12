#!/bin/bash

set -oue pipefail

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland