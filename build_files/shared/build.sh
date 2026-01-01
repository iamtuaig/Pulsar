#!/bin/bash

set -ouex pipefail

echo "::group:: Copy Files"

# Copy ISO list for `install-system-flaptaks`
install -Dm0644 -t /etc/ublue-os/ /ctx/flatpaks/*.list

# We need to remove this package here because lots of files we add from `projectbluefin/common` override the rpm files and they also go away when you do `dnf remove`
dnf5 remove -y ublue-os-just

# Copy Files to Container
rsync -rvK /ctx/system_files/shared/ /

mkdir -p /tmp/scripts/helpers
install -Dm0755 /ctx/build_files/shared/utils/ghcurl /tmp/scripts/helpers/ghcurl
export PATH="/tmp/scripts/helpers:$PATH"

echo "::endgroup::"

# Generate image-info.json
/ctx/build_files/base/00-image-info.sh

# Install Kernel and Akmods
/ctx/build_files/base/03-install-kernel-akmods.sh

# Install Additional Packages
/ctx/build_files/base/04-packages.sh

# Install Overrides and Fetch Install
/ctx/build_files/base/06-override-install.sh

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 
dnf5 install -y kitty fastfetch fish neovim rsms-inter-fonts solaar

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
