# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CLIProxyAPI 是一個 Go 語言的代理伺服器，提供 OpenAI/Gemini/Claude/Codex 相容的 API 介面給 CLI 工具使用。支援多種 OAuth 提供者（Claude Code、OpenAI Codex、Qwen Code、iFlow、Antigravity）並實現跨 AI 提供者的請求轉譯。

- Go 版本：1.24.0
- Module 路徑：`github.com/router-for-me/CLIProxyAPI/v6`

## Build & Run

```bash
# 建置
go build -o cli-proxy-api ./cmd/server

# 執行（預設讀取 ./config.yaml）
./cli-proxy-api

# 指定設定檔
./cli-proxy-api -config /path/to/config.yaml

# 啟用除錯模式
./cli-proxy-api -debug
```

## Testing

```bash
# 執行所有測試（含 internal 模組）
go test ./...

# 只執行 test 目錄的整合測試
go test ./test/...

# 執行特定模組測試
go test ./internal/translator/...
go test ./internal/api/...

# 執行特定測試函式
go test ./test/... -run TestThinkingConversion
```

## OAuth Login Commands

```bash
./cli-proxy-api -login              # Google Gemini
./cli-proxy-api -codex-login        # OpenAI Codex
./cli-proxy-api -claude-login       # Claude
./cli-proxy-api -qwen-login         # Qwen
./cli-proxy-api -iflow-login        # iFlow
./cli-proxy-api -antigravity-login  # Antigravity
```

額外參數：
- `-no-browser`: 不自動開啟瀏覽器
- `-oauth-callback-port N`: 自訂 OAuth 回調埠

## Architecture

```
cmd/server/main.go          # 入口點，CLI flag 解析
internal/
  ├── api/                  # API handlers 與 middleware
  │   ├── handlers/
  │   ├── middleware/
  │   └── modules/          # 含 amp provider 支援
  ├── translator/           # 格式轉譯層（Claude↔OpenAI↔Gemini↔etc）
  │   ├── init.go           # 註冊所有 translator pairs
  │   ├── claude/
  │   ├── codex/
  │   ├── gemini/
  │   ├── gemini-cli/
  │   ├── openai/
  │   └── antigravity/
  ├── auth/                 # OAuth 與認證
  ├── config/               # YAML 設定管理
  ├── store/                # Token 儲存後端（file/postgres/git/s3）
  ├── registry/             # Model 與 provider 註冊
  └── watcher/              # Config 熱更新
sdk/
  ├── cliproxy/             # 可嵌入式 SDK
  ├── auth/                 # Auth manager
  └── translator/           # Translation interfaces
```

### Key Patterns

1. **Translator Pattern**: `internal/translator/` 實現雙向格式轉換。新增 provider 時需在 `init.go` 註冊 translator pairs。
   - 目錄結構：`{source}/{target}/`（如 `claude/gemini/` = Claude 格式 → Gemini 格式）
   - 每個 pair 包含：`init.go`（註冊）、`*_request.go`（請求轉換）、`*_response.go`（回應轉換）

2. **Provider Registry**: 動態 provider 註冊系統，支援 round-robin 或 fill-first 負載平衡。

3. **Blank Import Init**: `cmd/server/main.go` 使用 `_ "...internal/translator"` 觸發 translator 註冊。

4. **SDK Embedding**: 可透過 `cliproxy.NewBuilder()` 嵌入使用。

## Configuration

設定檔：`config.yaml`（參考 `config.example.yaml`）

主要設定區塊：
- `port`: 監聽埠（預設 8317）
- `auth-dir`: 認證目錄（預設 `~/.cli-proxy-api`）
- `api-keys`: API 金鑰清單
- `gemini-api-key`, `codex-api-key`, `claude-api-key`: 各 provider 憑證
- `oauth-model-alias`: 模型別名對照
- `routing.strategy`: `round-robin` 或 `fill-first`

儲存後端（環境變數）：
- `PGSTORE_DSN`: PostgreSQL
- `GITSTORE_GIT_URL`: Git-backed
- `OBJECTSTORE_ENDPOINT`: S3/MinIO

## Release

使用 goreleaser 自動化建置與發布：

```bash
# 本地測試建置
goreleaser build --snapshot --clean

# 正式發布（需 GitHub token）
goreleaser release
```

## Upstream Sync

此專案為 [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) 的 fork。同步上游更新時保留本地修改：

```bash
# 首次設定 upstream remote（僅需執行一次）
git remote add upstream https://github.com/router-for-me/CLIProxyAPI.git

# 拉取上游更新
git fetch upstream

# 查看上游新增的 commits
git log --oneline HEAD..upstream/main

# 合併上游變更（保留本地修改）
git merge upstream/main -m "Merge upstream/main: sync with router-for-me/CLIProxyAPI"

# 推送到 origin
git push origin main
```

**本地獨特修改：**
- 管理介面來源改為 TW fork (`yelban/Cli-Proxy-API-Management-Center.TW`)
- Docker 部署範例 (`docker/`)
- CLAUDE.md 專案指引

## Commit Convention

```
feat(translator): description
fix(auth): description
chore(config): description
refactor(api): description
```

## SDK Documentation

- 基本用法：`docs/sdk-usage.md`
- 進階（executors & translators）：`docs/sdk-advanced.md`
- 存取控制：`docs/sdk-access.md`
- 設定監聽：`docs/sdk-watcher.md`
