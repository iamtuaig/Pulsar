#!/usr/bin/bash
echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# ------------------------------------------------------------
# Size / surface-area reductions
# ------------------------------------------------------------
# /usr is immutable on bootc; we keep the image lean.
rm -rf /usr/src
rm -rf /usr/share/doc

# ------------------------------------------------------------
# RPMDB consistency (guarded)
# ------------------------------------------------------------
# If kernel-devel is installed, remove it from rpmdb since /usr/src is removed above.
# Guarded so the build doesn't fail on bases where kernel-devel is not present.
if rpm -q kernel-devel >/dev/null 2>&1; then
  rpm --erase --nodeps kernel-devel
fi

# ------------------------------------------------------------
# Starship
# ------------------------------------------------------------
# Starship is installed from Fedora repos in 04-packages.sh for reproducibility.
# Shell initialization is handled via /etc/profile.d/00-starship.sh (repo-owned).
# Do NOT curl "latest" tarballs here; that makes builds non-reproducible.

echo "::endgroup::"
