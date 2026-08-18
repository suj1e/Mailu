#!/bin/sh
# Build acceleration for servers with restricted connectivity to
# docker.io / ghcr.io / github.com (e.g. mainland China).
#
# Usage: run from the repository root, BEFORE `docker buildx bake`:
#   ./scripts/build-cn.sh
#
# These seds patch the Dockerfiles locally and are intentionally NOT
# committed into the build files: the upstream URLs remain the source
# of truth, and this script is re-runnable on every fresh clone.
#
# Also create an accelerated builder once per host (see bottom).

set -eu

# 1) Pull the Mailu alpine base image through the NJU ghcr mirror
sed -i 's#ghcr.io/mailu/alpine:3.20.10#ghcr.nju.edu.cn/mailu/alpine:3.20.10#' core/base/Dockerfile

# 2) Download GitHub release tarballs through public proxy prefixes
#    (roundcube/carddav worked via ghproxy.net; snappymail needed gh-proxy.com)
sed -i 's#https://github.com/roundcube#https://ghproxy.net/https://github.com/roundcube#' webmails/Dockerfile
sed -i 's#https://github.com/mstilkerich#https://ghproxy.net/https://github.com/mstilkerich#' webmails/Dockerfile
sed -i 's#https://github.com/the-djmaze#https://gh-proxy.com/https://github.com/the-djmaze#' webmails/Dockerfile

echo "== Dockerfiles patched for CN network =="

# 3) BuildKit registry mirror for docker.io (daocloud); ghcr.io is handled
#    by the NJU mirror above. Recreate the builder only if not present yet.
if ! docker buildx ls | grep -q '^mailu-builder'; then
  cat > /tmp/buildkitd.toml <<'TOML'
[registry."docker.io"]
  mirrors = ["docker.m.daocloud.io"]
TOML
  docker buildx create --use --name mailu-builder \
    --buildkitd-config=/tmp/buildkitd.toml
  echo "== accelerated builder 'mailu-builder' created =="
fi

echo "Now run: docker buildx bake -f tests/build.hcl --load admin webmail front imap smtp antispam resolver"
