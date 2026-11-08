$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$html = (Resolve-Path (Join-Path $PSScriptRoot 'index.html')).Path
$outDir = Join-Path $repo 'assets\moments'
$runId = [Guid]::NewGuid().ToString('N')
$profile = Join-Path $env:TEMP "agentdna-moments-$runId-repo"

if (-not (Test-Path -LiteralPath $chrome)) {
  throw "Chrome not found at $chrome"
}

New-Item -ItemType Directory -Force -Path $outDir, $profile | Out-Null

$repoShot = Join-Path $outDir 'github-page.png'
$repoArgs = @(
  '--headless=new', '--disable-gpu', '--hide-scrollbars',
  '--window-size=1200,900', '--force-device-scale-factor=1',
  "--user-data-dir=$profile", "--screenshot=$repoShot",
  'https://github.com/540709984-dotcom/earth-online-agentdna'
)
$repoProcess = Start-Process -FilePath $chrome -ArgumentList $repoArgs -Wait -PassThru -NoNewWindow
if (-not (Test-Path -LiteralPath $repoShot) -or (Get-Item -LiteralPath $repoShot).Length -eq 0) {
  throw 'Failed to capture GitHub repository page.'
}

$names = @(
  '01-cover.png',
  '02-collaboration-chain.png',
  '03-dna-mapping.png',
  '04-four-bot-roles.png',
  '05-five-skills.png',
  '06-error-gates.png',
  '07-research-evidence.png',
  '08-workbuddy-deployment.png',
  '09-github-release.png'
)

$uri = [System.Uri]::new($html).AbsoluteUri
for ($i = 1; $i -le 9; $i++) {
  $target = Join-Path $outDir $names[$i - 1]
  $cardProfile = Join-Path $env:TEMP "agentdna-moments-$runId-card-$i"
  $cardArgs = @(
    '--headless=new', '--disable-gpu', '--hide-scrollbars',
    '--window-size=1080,1440', '--force-device-scale-factor=1',
    "--user-data-dir=$cardProfile", "--screenshot=$target",
    "$uri`?card=$i"
  )
  $cardProcess = Start-Process -FilePath $chrome -ArgumentList $cardArgs -Wait -PassThru -NoNewWindow
  if (-not (Test-Path -LiteralPath $target) -or (Get-Item -LiteralPath $target).Length -eq 0) {
    throw "Failed to render card $i."
  }
}

Get-ChildItem -LiteralPath $outDir -Filter '*.png' | Sort-Object Name | Select-Object Name, Length
