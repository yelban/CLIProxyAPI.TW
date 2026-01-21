# CLIProxyAPI Docker 部署指南

## 目錄結構

```
your-project/
├── docker-compose.yml
├── .env
├── CLIProxyAPI.TW/          # clone 專案（作為 build context）
└── cliproxyapi/
    ├── config.docker.yaml   # 設定檔（從 docker/ 複製並修改）
    └── auths/               # OAuth token 目錄（自動建立）
```

## 快速開始

1. **Clone 專案**
   ```bash
   git clone https://github.com/yelban/CLIProxyAPI.TW.git
   ```

2. **準備設定檔**
   ```bash
   mkdir -p ./cliproxyapi/auths
   cp ./CLIProxyAPI.TW/docker/config.docker.yaml ./cliproxyapi/
   ```

3. **修改 config.docker.yaml**
   - 設定 `api-keys`（客戶端認證金鑰）
   - 設定 API Key 或 OAuth 認證

4. **加入 docker-compose.yml**
   - 將 `docker-compose.snippet.yml` 內容加入你的 services 區塊

5. **啟動服務**
   ```bash
   docker-compose up -d cliproxyapi
   ```

## OAuth 登入（可選）

若需使用 OAuth 登入（Gemini/Claude/Codex/Qwen/iFlow/Antigravity）：

1. **在本機執行登入**
   ```bash
   cd ./CLIProxyAPI.TW

   # 建置並登入
   go build -o cli-proxy-api ./cmd/server
   ./cli-proxy-api -login              # Google Gemini
   ./cli-proxy-api -claude-login       # Claude
   ./cli-proxy-api -codex-login        # OpenAI Codex
   ./cli-proxy-api -antigravity-login  # Antigravity
   ```

2. **複製 token 到容器掛載目錄**
   ```bash
   cp -r ~/.cli-proxy-api/* ./cliproxyapi/auths/
   ```

3. **重啟容器**
   ```bash
   docker-compose restart cliproxyapi
   ```

## 環境變數（.env）

```bash
# Docker build 參數
CLIPROXYAPI_VERSION=v6.0.0
TZ=Asia/Taipei
```

> **注意**：API keys 等設定請在 `config.docker.yaml` 中設定，不支援環境變數。

## Nginx Proxy Manager 反向代理

在 NPM 中新增 Proxy Host：
- Domain: `cliproxyapi.yourdomain.com`
- Forward Hostname: `cliproxyapi`
- Forward Port: `8317`
- 啟用 SSL（Let's Encrypt）
