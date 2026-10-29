# index.html의 굿즈 목록에서 [JAN, 이미지 경로]를 뽑아 300px 이미지를 img/<JAN>.jpg 로 저장 (이미 있는 파일은 건너뜀)
# 사용법: powershell -NoProfile -ExecutionPolicy Bypass -File fetch-images.ps1
$root = $PSScriptRoot
$outDir = Join-Path $root "img"
$src = Get-Content -Raw -Encoding UTF8 (Join-Path $root "index.html")
$items = [regex]::Matches($src, '\["(\d{13})", "((?:files|products)/[^"]+)"')
New-Item -ItemType Directory -Force $outDir | Out-Null
$fail = @()
foreach ($m in $items) {
  $jan = $m.Groups[1].Value; $path = $m.Groups[2].Value
  $out = Join-Path $outDir "$jan.jpg"
  if (Test-Path $out) { continue }
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "https://cdn.shopify.com/s/files/1/0626/7142/1681/$($path)?width=300" -OutFile $out -ErrorAction Stop
  } catch { $fail += $jan }
}
$files = Get-ChildItem $outDir -Filter *.jpg
"items=$($items.Count) files=$($files.Count) totalKB=$([math]::Round(($files | Measure-Object Length -Sum).Sum / 1KB)) failed=$($fail -join ',')"
