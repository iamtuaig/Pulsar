# Bump this when you want to rebase the image to a newer Fedora release.
# ARG FEDORA_RELEASE=43
ARG BREWIMAGE="ghcr.io/ublue-os/brew:latest"
ARG BREWIMAGE_SHA=""


# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image

# Fedora COSMIC Atomic (bootable container / rpm-ostree)
# FROM quay.io/fedora-ostree-desktops/cosmic-atomic:${FEDORA_RELEASE}
FROM ghcr.io/ublue-os/base-main:latest
FROM scratch AS ctx
FROM ${BREWIMAGE}@${BREWIMAGESHA} AS brew

COPY --from=brew /systemfiles /systemfiles/shared

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
