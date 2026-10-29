# 간단한 로컬 정적 서버: powershell -File serve.ps1 → http://localhost:5173 (PORT 환경 변수가 있으면 그 포트)
$root = $PSScriptRoot
$port = if ($env:PORT) { $env:PORT } else { 5173 }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$port"
$types = @{ ".html" = "text/html; charset=utf-8"; ".js" = "text/javascript"; ".css" = "text/css"; ".png" = "image/png"; ".jpg" = "image/jpeg"; ".svg" = "image/svg+xml" }
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = $ctx.Request.Url.AbsolutePath.TrimStart("/")
  if ($path -eq "") { $path = "index.html" }
  $file = Join-Path $root $path
  if (Test-Path $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ext = [System.IO.Path]::GetExtension($file)
    if ($types.ContainsKey($ext)) { $ctx.Response.ContentType = $types[$ext] }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
