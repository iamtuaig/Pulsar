#!/bin/bash
set -ouex pipefail

echo "::group:: Copy Files"

# Copy ISO list(s) for `install-system-flatpaks`
install -Dm0644 -t /etc/ublue-os/ /ctx/flatpaks/*.list

# Remove ublue-os-just here because some files copied from common layers can
# override rpm-owned files and later removals would remove them.
dnf5 remove -y ublue-os-just

# Copy repo-provided system files into the container filesystem
# (Your Containerfile should also COPY system_files/ /; this is for build pipeline layout)
rsync -rvK /ctx/system_files/shared/ /

# Helper used by some build steps
mkdir -p /tmp/scripts/helpers
install -Dm0755 /ctx/build_files/shared/utils/ghcurl /tmp/scripts/helpers/ghcurl
export PATH="/tmp/scripts/helpers:$PATH"

echo "::endgroup::"

# Generate image-info.json and os-release adjustments
/ctx/build_files/base/00-image-info.sh

# Install Additional Packages (Fedora first, then isolated COPR as needed)
/ctx/build_files/base/04-packages.sh

# Overrides / cleanup / fetch installs
/ctx/build_files/base/06-override-install.sh
