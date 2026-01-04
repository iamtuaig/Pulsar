# Bump this when you want to rebase the image to a newer Fedora release.
ARG FEDORA_RELEASE=43

# Brew image pinning (optional but recommended)
ARG BREWIMAGE="ghcr.io/ublue-os/brew:latest"
ARG BREWIMAGE_SHA=""

# ------------------------------------------------------------
# Build context stage (files only; never ends up in final image)
# ------------------------------------------------------------
FROM scratch AS ctx
COPY assets /
COPY build_files /
COPY flatpaks /
COPY logos /
COPY system_files /
COPY wallpapers /

# ------------------------------------------------------------
# Brew stage (optional)
# If BREWIMAGE_SHA is empty, you should NOT use the @sha form.
# ------------------------------------------------------------
FROM ${BREWIMAGE} AS brew

# ------------------------------------------------------------
# Final image stage (your actual OS image)
# ------------------------------------------------------------
FROM quay.io/fedora-ostree-desktops/cosmic-atomic:${FEDORA_RELEASE}

# Copy brew system files into the final image (path uses underscore)
COPY --from=brew /system_files /system_files/shared

### MODIFICATIONS
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
