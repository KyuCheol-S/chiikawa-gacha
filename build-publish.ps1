# claude.ai 게시용 페이지 만들기: index.html에서 문서 껍데기(doctype/html/head/body, charset·viewport meta)를 빼서
# publish/index.html로 저장합니다. 게시할 때 껍데기는 claude.ai가 씌워 줍니다.
# 사용법: powershell -NoProfile -ExecutionPolicy Bypass -File build-publish.ps1
$root = $PSScriptRoot
$src = Get-Content -Raw -Encoding UTF8 (Join-Path $root "index.html")
$patterns = @('<!doctype html>', '<html[^>]*>', '</html>', '<head>', '</head>', '<body>', '</body>', '<meta charset="utf-8">', '<meta name="viewport"[^>]*>')
foreach ($p in $patterns) { $src = [regex]::Replace($src, "(?im)^\s*$p\s*\r?\n", "") }
$outDir = Join-Path $root "publish"
New-Item -ItemType Directory -Force $outDir | Out-Null
[System.IO.File]::WriteAllText((Join-Path $outDir "index.html"), $src, (New-Object System.Text.UTF8Encoding $false))
"wrote publish/index.html ($([math]::Round($src.Length / 1KB)) KB chars)"
