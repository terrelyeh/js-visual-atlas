#!/bin/sh
# index.html is a page fragment (the claude.ai Artifact adds the document skeleton);
# wrap it into a full HTML document for static hosting.
set -e
mkdir -p dist
{
  printf '%s\n' '<!doctype html>' '<html lang="zh-Hant">' '<head>' \
    '<meta charset="utf-8">' \
    '<meta name="viewport" content="width=device-width, initial-scale=1">' \
    '<meta name="description" content="12 個 JavaScript 視覺套件與瀏覽器原生 API、60 種即時效果，全部在瀏覽器裡即時生成，沒有任何圖片、影片或音檔。">' \
    '<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 32 32%27%3E%3Crect width=%2732%27 height=%2732%27 rx=%277%27 fill=%27%23F2B83A%27/%3E%3Ctext x=%2716%27 y=%2722%27 font-family=%27Arial%27 font-weight=%27900%27 font-size=%2715%27 text-anchor=%27middle%27 fill=%27%232C3345%27%3EJS%3C/text%3E%3C/svg%3E">' \
    '</head>' '<body>'
  cat index.html
  printf '%s\n' '</body>' '</html>'
} > dist/index.html
