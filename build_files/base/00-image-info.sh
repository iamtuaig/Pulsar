#!/usr/bin/env bash
echo "::group:: ===$(basename "$0")==="

set -xeuo pipefail

# ------------------------------------------------------------
# Pulsar identity
# ------------------------------------------------------------
IMAGE_PRETTY_NAME="Pulsar"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/iamtuaig"
DOCUMENTATION_URL="https://github.com/iamtuaig/Pulsar#readme"
SUPPORT_URL="https://github.com/iamtuaig/Pulsar/issues"
BUG_SUPPORT_URL="https://github.com/iamtuaig/Pulsar/issues"
CODE_NAME="Cosmic"

# Template provides VERSION (or fallback)
VERSION="${VERSION:-00.00000000}"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"

# Prefer the actual build tag (e.g. v0.1.0) when set; else "latest"
IMAGE_REF_TAG="${UBLUE_IMAGE_TAG:-latest}"
IMAGE_REF="ostree-unverified-registry:ghcr.io/iamtuaig/pulsar:${IMAGE_REF_TAG}"

# Image Flavor detection (keep for future expansion)
image_flavor="main"
if [[ "${IMAGE_NAME:-}" =~ nvidia-open ]]; then
  image_flavor="nvidia-open"
fi

# ------------------------------------------------------------
# image-info.json (ublue tooling)
# ------------------------------------------------------------
cat > "${IMAGE_INFO}" <<EOF
{
  "image-name": "${IMAGE_NAME:-pulsar}",
  "image-flavor": "${image_flavor}",
  "image-vendor": "${IMAGE_VENDOR:-iamtuaig}",
  "image-ref": "${IMAGE_REF}",
  "image-tag": "${UBLUE_IMAGE_TAG:-}",
  "base-image-name": "${BASE_IMAGE_NAME:-cosmic-atomic}",
  "fedora-version": "${FEDORA_MAJOR_VERSION:-43}"
}
EOF

# ------------------------------------------------------------
# /usr/lib/os-release adjustments
# ------------------------------------------------------------
OS_RELEASE="/usr/lib/os-release"

# Helper: only replace if key exists, else append
replace_or_append() {
  local key="$1"
  local value="$2"
  if grep -qE "^${key}=" "${OS_RELEASE}"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "${OS_RELEASE}"
  else
    echo "${key}=${value}" >> "${OS_RELEASE}"
  fi
}

# These are common in uBlue-derived images
replace_or_append "VARIANT_ID" "${IMAGE_NAME:-pulsar}"
replace_or_append "PRETTY_NAME" "\"${IMAGE_PRETTY_NAME} (Version: ${VERSION})\""
replace_or_append "NAME" "\"${IMAGE_PRETTY_NAME}\""
replace_or_append "HOME_URL" "\"${HOME_URL}\""
replace_or_append "DOCUMENTATION_URL" "\"${DOCUMENTATION_URL}\""
replace_or_append "SUPPORT_URL" "\"${SUPPORT_URL}\""
replace_or_append "BUG_REPORT_URL" "\"${BUG_SUPPORT_URL}\""
replace_or_append "VERSION_CODENAME" "\"${CODE_NAME}\""
replace_or_append "VERSION" "\"${VERSION} (${BASE_IMAGE_NAME^})\""

# Ensure ID/ID_LIKE reflect Pulsar while retaining fedora lineage
# Replace "ID=fedora" if present; otherwise enforce ID/ID_LIKE entries
if grep -qE "^ID=fedora$" "${OS_RELEASE}"; then
  sed -i "s|^ID=fedora$|ID=${IMAGE_PRETTY_NAME,,}\nID_LIKE=\"${IMAGE_LIKE}\"|" "${OS_RELEASE}"
else
  replace_or_append "ID" "${IMAGE_PRETTY_NAME,,}"
  replace_or_append "ID_LIKE" "\"${IMAGE_LIKE}\""
fi

# Remove RHEL-specific metadata keys if present
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" "${OS_RELEASE}"

# Normalize CPE + hostname (if keys exist)
replace_or_append "CPE_NAME" "\"cpe:/o:universal-blue:${IMAGE_PRETTY_NAME,,}:${VERSION}\""
replace_or_append "DEFAULT_HOSTNAME" "\"${IMAGE_PRETTY_NAME,,}\""

# OSTree image version key
replace_or_append "OSTREE_VERSION" "'${VERSION}'"

# Optional build id
if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
  replace_or_append "BUILD_ID" "\"${SHA_HEAD_SHORT}\""
fi

# systemd 249+ image metadata keys (append-only; harmless if already present)
if ! grep -qE '^IMAGE_ID=' "${OS_RELEASE}"; then
  echo "IMAGE_ID=\"${IMAGE_NAME:-pulsar}\"" >> "${OS_RELEASE}"
fi
if ! grep -qE '^IMAGE_VERSION=' "${OS_RELEASE}"; then
  echo "IMAGE_VERSION=\"${VERSION}\"" >> "${OS_RELEASE}"
fi

# ------------------------------------------------------------
# Fix issues caused by ID no longer being fedora (guarded)
# ------------------------------------------------------------
# Some Fedora tooling expects EFIDIR=fedora; guard in case the script doesn't exist on this base.
if [[ -f /usr/sbin/grub2-switch-to-blscfg ]]; then
  sed -i "s|^EFIDIR=.*|EFIDIR=\"fedora\"|" /usr/sbin/grub2-switch-to-blscfg
fi

echo "::endgroup::"