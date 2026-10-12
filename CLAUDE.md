# CLAUDE.md — Project Context

> Last updated: 2026-10-12

## Project Overview

JS 視覺生態圖譜：用 12 個示範（每個 5 個分頁，共 60 種效果）介紹 JavaScript 視覺套件和瀏覽器原生 API。所有畫面和聲音都是瀏覽器即時生成，沒有圖片、影片或音檔。主要用途是當作「效果目錄＋給 AI 的提示詞範本庫」，做官網或網頁影片時挑效果用。
功能清單詳見 [README.md](README.md)。

## Tech Stack

- 單一檔案 `index.html`（約 4,500 行）：HTML 片段 + `<style>` + 一個 IIFE `<script>`，沒有框架、沒有打包工具、沒有 npm 相依。
- 套件從 CDN 動態載入（`CDN` 物件 + `loadScript()`），切到該示範時才載入。版本固定：roughjs 4.6.6、p5.js 1.9.4、gsap 3.13.0（+ ScrollTrigger、SplitText、Flip、MotionPathPlugin、DrawSVGPlugin）、animejs 3.2.2（v3 語法）、d3 7.9.0、pixi.js 7.4.2（v7 API）、matter-js 0.19.0、three.js r149（舊 API：`outputEncoding`、`sRGBEncoding`）、tone 14.8.49。
- Canvas 2D、Falling Sand、GLSL 三個示範不用套件（原生 API）。

## Directory Structure

- `index.html`：整個網站。是**頁面片段**（沒有 `<!doctype>`），因為同一份檔案也發布成 claude.ai Artifact。
- `build.sh`：把片段包成完整 HTML 輸出到 `dist/index.html`（Vercel 用）。`dist/` 不進 git。
- `vercel.json`：`buildCommand: sh build.sh`、`outputDirectory: dist`。

## Architecture & Data Flow

**資料**（`<script>` 開頭）
- `BASES`：6 種瀏覽器 API。`DEMOS`：12 個示範（`id, name, cat, base, ver, blurb, fit, code, site`）。`base` 是**示範實際用到的** API（資訊卡、示範卡片色點、畫面左上角徽章都讀它）。
- `CATS`：上方圖譜「這些套件站在哪一層」的資料，列的是**套件本身支援的** API，跟 `DEMOS.base` 分開維護（例如圖譜的 Three.js 連到 WebGPU，`DEMOS` 只有 WebGL）。
- `ASK`（各示範第 1 頁）和 `CANVAS_ASK`、`D3_ASK`、`GS_ASK`… 等 `*_ASK`：提示詞 `{ terms, prompt }`。`*_CODE`：程式碼片段（HTML 字串，用 `K()`、`S_()`、`N_()`、`C_()` 上色）。

**示範與分頁**
- `MOUNT.<id> = (el, api) => tabbed(el, api, '<id>', TABS)`；每個分頁 `{ name, mount, play, code, ask }`，`mount(host)` 回傳 cleanup。
- `tabbed()` 換分頁時呼叫 `api.setCode / setAsk / setPlay`，並更新網址 `#<id>/<n>`（`history.replaceState`）。`tabMemory[id]` 記住每個示範的分頁；`readHash()` 開頁時解析 `#gsap/3`。第一次直接開首頁（沒有 hash）時網址保持乾淨（`api.hashTab`）。
- `select(i)`：清掉舊示範 → `renderInfo(d)` → 載入 CDN → `MOUNT[id]`。

**資訊卡與提示詞**
- `renderInfo(d)` 畫右邊資訊卡：介紹、API、這一頁怎麼玩（`#info-play`，由 `setPlay` 填）、適合拿來做、程式碼片段（`#ask-code`，`setCode` 填，經 `codeLines()` 每行包一個 `.ln` 做懸掛縮排）、官方網站。
- `renderAsk(a)` 畫下方全寬的 `#ask`「跟 AI 這樣說」：五步驟、關鍵詞、網頁版／影片版切換、提示詞、兩顆複製按鈕。影片版用 `videoize()`（拿掉「互動：」段 + 加 `VIDEO_NOTE`；Tone.js 多一句聲音分開錄）。
- `tabLink(d)`：在 Artifact iframe 或 `file://` 時一律回傳公開網站 `SITE` 的網址。`copyText()` 有 `execCommand` 後備。
- localStorage：`jsatlas-demo`（上次看的示範）、`jsatlas-video`（影片版開關）。

**共用 helper**：`dkBar`（右下角按鈕列）、`dkNote`（左下角提示）、`fitFoot`（手機上把提示疊到按鈕列上方，回傳底部佔用高度）、`phr`（中文詞組不斷行）、`glQuad`（全螢幕 shader）、`threeBase`、`toneKit`（淡出後 dispose）、`roughPaper` / `sketchIn`。

**版面**（CSS）
- `.studio` 兩欄 `minmax(0,1fr) 360px`、`align-items: stretch`：左欄 `.stage-col` = 示範畫面 + 按鈕列 + 12 張示範卡片（`.picker`，6×2）；右欄 `.info` 跟左欄等高；`.ask` 跨兩欄。
- ≥1081px 時 `.info { contain: size }`，卡片永遠不會比左欄高，程式碼片段吃剩下的高度。
- ≤1080px 疊成一欄（示範卡片 4 欄）；≤640px 示範卡片變橫向滑動、按鈕列只留圖示一行（≥381px 保留「自動巡覽」字）。

## Conventions

- **提示詞格式**（60 段都照這個寫）：開頭一句「用 X 做 Y」，接著依序 `畫面：` `怎麼動：` `互動：` `限制：` 四個小標（畫面上自動標色換行、複製時分行，`videoize` 也靠「互動：…限制：」切）。可替換的主題用【】括起來；括號外是效果寫法。數字、秒數、按鈕名稱要跟示範程式一致。
- **關鍵詞 `terms`** 只放跟效果有關的詞，不放主題詞。
- **`play`**：每個分頁一句「這一頁怎麼玩」，寫畫面上實際有的操作和按鈕名稱。
- **左下角提示 `dkNote`**：白話「動作 → 結果」，最多兩件事，不放技術名詞。
- 程式碼片段的上色 span 不可跨行（`codeLines` 依 `\n` 切行）。
- UI：顏色放 `:root` token（有深色模式），不用純黑，數字用 `tabular-nums`。文字用繁體中文。

## Current Status

功能清單詳見 [README.md](README.md)。版面在 2026-10-12 定稿。

### 🔜 Next Steps

- 目前沒有待辦。
- 未實測：瀏覽器擋住剪貼簿時，「複製這一頁的連結」會改成直接顯示網址 6 秒（測試環境模擬不出來）。

## Deployment

- **兩個發布點，改完 `index.html` 兩邊都要更新**：
  1. claude.ai Artifact（私人）：https://claude.ai/artifact/PAjau4ZP8gaTMR3mzc9aZs，用 Artifact 工具以同一個檔案路徑重新發布。
  2. Vercel 公開站：https://js-visual-atlas.vercel.app（專案 `js-visual-atlas`，team `ty510s-projects`），push 到 `main` 自動部署。只分享這個網址，hash 部署網址需要登入。
- 本機預覽：`sh build.sh && open dist/index.html`。
- commit 訊息用繁體中文，結尾加 `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`。

## Common Pitfalls

1. **Vercel 自動部署偶爾失敗**（Error、0ms、沒有 log）。push 後要用 curl 確認公開網站真的有新內容；失敗就 `vercel redeploy <失敗的部署網址> --scope ty510s-projects`。
2. **`.info` 的 `contain: size`**：資訊卡內容（尤其程式碼片段）超出不會撐高卡片，而是被裁掉。改程式碼片段或資訊卡內容後，要在 1200 寬度把 60 個分頁跑一遍，確認 `#ask-code` 沒有 scrollHeight > clientHeight。
3. **手機版 `.dk-note` 的 container query** 會把提示改成 `bottom: 54px !important`。`top` 定位的提示和 PBR 座標標籤（`.dk-lbl`）已排除；新提示若放在按鈕列旁，記得在 mount 裡呼叫 `fitFoot(el)`。
4. **`text-wrap: pretty` 會讓子層 `.nw`（nowrap）失效**，不要加在含 `.nw` 的父層。
5. **Tone.js**：步進音序器用 `Tone.Clock`，不用 `Tone.Transport`（會跟背景配樂 `Music` 衝突）；音效每次 new 一個 synth、播完 dispose。
6. **PixiJS**：共用貼圖的分頁要自己寫 teardown，避免同一張 texture 被 destroy 兩次（"Cannot read properties of null (reading 'dispose')"）。
7. **Matter.js**：`MouseConstraint` 要移除 Mouse 的 wheel 監聽，不然會擋住頁面捲動。D3 / Three 的縮放也只接 ⌘/Ctrl + 滾輪。
8. **Artifact 裡是 iframe**：`location` 不是公開網址，分享連結一律走 `tabLink()`。
9. **測試**：用 headless Chrome（playwright-core 在 `~/.nvm/versions/node/v25.5.0/lib/node_modules/@playwright/cli/node_modules/playwright-core`，加 `--use-angle=swiftshader --enable-unsafe-swiftshader`）。網路慢時 Google Fonts 會卡住截圖，攔掉 `fonts.googleapis/gstatic` 的請求再跑。每次改完要切過 60 個分頁確認沒有 pageerror，並在 390、360 手機寬度截圖。
