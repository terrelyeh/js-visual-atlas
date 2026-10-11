# JS 視覺生態圖譜

12 個 JavaScript 視覺套件與瀏覽器原生 API、60 種即時效果。這一頁沒有任何圖片、影片或音檔，所有畫面和聲音都是瀏覽器裡的 JavaScript 即時算出來的。

公開網址：https://js-visual-atlas.vercel.app

## 檔案

- `index.html`：整個網站，單一檔案。它是頁面片段（沒有 `<!doctype>`），因為同一份檔案也發布成 claude.ai Artifact，Artifact 會自動補上外層結構。
- `build.sh`：把 `index.html` 包成完整的 HTML 頁面，輸出到 `dist/`。
- `vercel.json`：告訴 Vercel 用 `build.sh` 打包、發布 `dist/`。

## 部署

推到 `main` 就會自動部署到正式網址。推到其他分支會產生預覽網址（需要登入 Vercel 才看得到）。

本機預覽：

```sh
sh build.sh && open dist/index.html
```
