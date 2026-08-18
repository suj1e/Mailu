#!/bin/sh
# Mailu fork update script (run on the server, in the repo root)
#
# Keeps the fork in sync with origin/notion-2024.06 and rebuilds the
# locally-built images with the CN-network acceleration applied.
#
# Usage:  ./scripts/update.sh [service...]
#   no args  -> rebuild all local images (admin webmail front imap smtp antispam resolver)
#   args     -> rebuild only the named targets, e.g.  ./scripts/update.sh webmail

set -eu

BRANCH=notion-2024.06
REPO=https://ghproxy.net/https://github.com/suj1e/Mailu.git

# 1) drop local Dockerfile edits (build-cn.sh re-applies them below)
git checkout -- webmails/Dockerfile 2>/dev/null || true

# 2) pull the branch (works even if a previous pull left the repo dirty)
git pull "$REPO" "$BRANCH"

# 3) re-apply CN-network build patches
bash scripts/build-cn.sh

# 4) rebuild and load the images (default set, or the targets you passed)
if [ "$#" -gt 0 ]; then
  docker buildx bake -f tests/build.hcl --load "$@"
else
  docker buildx bake -f tests/build.hcl --load admin webmail front imap smtp antispam resolver
fi

echo ""
echo "== done. If you changed config/.env, recreate the containers: =="
echo "   cd /app/mailu && docker-compose up -d --force-recreate"
