#!/usr/bin/env bash
# 在 wks 上執行：拉最新程式碼、重建映像、重啟 cli-proxy-api。
# 用法：bash /home/orz99/zoo/CLIProxyAPI.TW/deploy/wks-update.sh
# 說明：deploy/WKS.md
set -euo pipefail
REPO=/home/orz99/zoo/CLIProxyAPI.TW
STACK=/home/orz99/zoo
SVC=cli-proxy-api

cd "$REPO"
echo "== git pull（只接受 fast-forward）=="
git pull --ff-only
COMMIT=$(git rev-parse --short HEAD)
echo "== 目前版本：$(git log -1 --format='%h %ci %s')"

cd "$STACK"
echo "== 重建映像 =="
docker compose build \
  --build-arg VERSION="tw-$COMMIT" \
  --build-arg COMMIT="$COMMIT" \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$SVC"

echo "== 重啟容器 =="
docker compose up -d "$SVC"
for _ in $(seq 1 18); do
  [ "$(docker inspect -f '{{.State.Health.Status}}' "$SVC")" = healthy ] && break
  sleep 5
done
docker compose ps "$SVC"
curl -s -o /dev/null -w "loopback /healthz HTTP %{http_code}\n" http://127.0.0.1:58317/healthz
docker exec nginx_proxy curl -s -o /dev/null -w "nginx_proxy → $SVC /management.html HTTP %{http_code}\n" "http://$SVC:8317/management.html"
