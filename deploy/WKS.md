# wks 部署紀錄

本 fork 部署在 wks（Hostinger VPS），服務名 `cli-proxy-api`，2026-09-17 上線。通用流程見本機 `~/.claude/guides/wks-deploy.md`。

| 項目 | 值 |
|------|----|
| 網址 | https://cpa.beyondsearchai.com |
| 管理介面 | https://cpa.beyondsearchai.com/management.html |
| 流量路徑 | Cloudflare 橘雲 → nginx_proxy（NPM，萬用憑證 `*.beyondsearchai.com`，無 Basic Auth）→ `cli-proxy-api:8317` |
| loopback | `127.0.0.1:58317` |
| 程式碼 | `/home/orz99/zoo/CLIProxyAPI.TW`（https clone，追蹤 `main`，sparse-checkout 排除 `docs/`） |
| compose | `/home/orz99/zoo/docker-compose.yml` 的 `cli-proxy-api` 區塊 |
| 映像 | `ab/cli-proxy-api:latest`，記憶體上限 512MB |
| 資料 | `/home/orz99/zoo/cli-proxy-api-data/`：`config.yaml`（權限 600）、`auths/`、`logs/`、`plugins/` |

## 機密

都在 `/home/orz99/zoo/.env`，只記鍵名：

- `CPA_MANAGEMENT_PASSWORD`：管理介面的管理金鑰。以 `MANAGEMENT_PASSWORD` 注入容器，設定後會自動允許遠端管理，所以 `config.yaml` 的 `secret-key` 留空。
- `CPA_API_KEY`：客戶端呼叫 API 用，寫在 `config.yaml` 的 `api-keys`。

同一個 IP 連續輸錯管理金鑰 5 次會被封鎖 30 分鐘。

## 管理介面來源

`config.yaml` 的 `remote-management.panel-github-repository` 指向 `https://github.com/yelban/Cli-Proxy-API-Management-Center.TW`，服務會從該 repo 最新 release 下載 `management.html`。更新介面只要在那個 repo 發新 release。

## 更新

本機推送 `main` 後：

```bash
ssh wks 'bash /home/orz99/zoo/CLIProxyAPI.TW/deploy/wks-update.sh'
```

## 注意事項

- 只開 8317。上游 compose 的 8085、1455 等是本機 OAuth 回呼埠，伺服器上不開；在管理介面登入帳號後，把回呼網址手動貼回。
- 修改金鑰：改 `.env` 後執行 `docker compose up -d cli-proxy-api`。
