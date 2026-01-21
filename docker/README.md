# CLIProxyAPI Docker 部署指南

## 目錄結構

將以下檔案複製到你的 docker-compose.yml 同級目錄：

```
your-project/
├── docker-compose.yml
├── .env
└── cliproxyapi/
    ├── Dockerfile          # 從專案根目錄複製
    ├── config.yaml         # 從此目錄複製並修改
    ├── auth/               # OAuth token 目錄（自動建立）
    └── (專案原始碼...)     # 如需本地建置
```

## 快速開始

1. **複製檔案**
   ```bash
   mkdir -p ./cliproxyapi
   cp /path/to/CLIProxyAPI.TW/Dockerfile ./cliproxyapi/
   cp /path/to/CLIProxyAPI.TW/docker/config.docker.yaml ./cliproxyapi/config.yaml
   cp -r /path/to/CLIProxyAPI.TW/* ./cliproxyapi/  # 本地建置需要
   ```

2. **修改 config.yaml**
   - 設定 `api-keys`（客戶端認證金鑰）
   - 設定 API Key 或 OAuth 認證

3. **加入 docker-compose.yml**
   - 將 `docker-compose.snippet.yml` 內容加入你的 services 區塊

4. **啟動服務**
   ```bash
   docker-compose up -d cliproxyapi
   ```

## OAuth 登入（可選）

若需使用 OAuth 登入（Gemini/Claude/Codex/Qwen/iFlow/Antigravity）：

1. **在本機執行登入**
   ```bash
   # 進入專案目錄
   cd /path/to/CLIProxyAPI.TW

   # 建置並登入
   go build -o cli-proxy-api ./cmd/server
   ./cli-proxy-api -login              # Google Gemini
   ./cli-proxy-api -claude-login       # Claude
   ./cli-proxy-api -codex-login        # OpenAI Codex
   ./cli-proxy-api -antigravity-login  # Antigravity
   ```

2. **複製 token 到容器掛載目錄**
   ```bash
   cp -r ~/.cli-proxy-api/* ./cliproxyapi/auth/
   ```

3. **重啟容器**
   ```bash
   docker-compose restart cliproxyapi
   ```

## 環境變數（.env）

```bash
# CLIProxyAPI
CLIPROXYAPI_VERSION=v6.0.0
TZ=Asia/Taipei
```

## Nginx Proxy Manager 反向代理

在 NPM 中新增 Proxy Host：
- Domain: `cliproxyapi.yourdomain.com`
- Forward Hostname: `cliproxyapi`
- Forward Port: `8317`
- 啟用 SSL（Let's Encrypt）
