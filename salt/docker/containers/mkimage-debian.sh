#!/bin/bash -xe

BUILD_DIR="$(mktemp -d ${TMPDIR:-/var/tmp}/mkimage-debian.XXXXXXXXXX)"
CODENAME="$(lsb_release -cs)"
VERSION_MAJOR="$(lsb_release -rs)"

debootstrap --variant=buildd "${CODENAME}" "${BUILD_DIR}/rootfs"

# Docker mounts tmpfs at /dev and procfs at /proc so we can remove them.
rm -rf "${BUILD_DIR}/rootfs/dev" "${BUILD_DIR}/rootfs/proc"
mkdir -p "${BUILD_DIR}/rootfs/dev" "${BUILD_DIR}/rootfs/proc"

# Prepare and compress the root filesystem tarball.
tar --numeric-owner -cJf "${BUILD_DIR}/rootfs.tar.xz" -C "${BUILD_DIR}/rootfs" --transform='s,^./,,' .

# Author the Dockerfile and build the image.
cat > "${BUILD_DIR}/Dockerfile" << EOF
FROM scratch
ADD rootfs.tar.xz /
CMD ["bash"]
EOF

read VERSION < "${BUILD_DIR}/rootfs/etc/debian_version"

docker build -t "debian:latest" -t "debian:${CODENAME}" -t "debian:${VERSION_MAJOR}" -t "debian:${VERSION}" -t "$(hostname -f):443/debian:latest" -t "$(hostname -f):443/debian:${CODENAME}" -t "$(hostname -f):443/debian:${VERSION_MAJOR}" -t "$(hostname -f):443/debian:${VERSION}" "${BUILD_DIR}"

docker push "$(hostname -f):443/debian:latest"
docker push "$(hostname -f):443/debian:${CODENAME}"
docker push "$(hostname -f):443/debian:${VERSION_MAJOR}"
docker push "$(hostname -f):443/debian:${VERSION}"

# Cleanup build directory.
rm -rf "${BUILD_DIR}"
