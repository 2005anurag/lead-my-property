$content = Get-Content -Path "index.html" -Raw

$urls = @()
$pattern1 = 'https?://[^\s''">]+\.(?:png|jpg|jpeg|svg|glb|ico)'
$pattern2 = 'https?://files\.peachworlds\.com/[^\s''">]+'

$matches1 = [regex]::Matches($content, $pattern1)
foreach ($m in $matches1) {
    $urls += $m.Value
}
$matches2 = [regex]::Matches($content, $pattern2)
foreach ($m in $matches2) {
    $urls += $m.Value
}

$urls = $urls | Select-Object -Unique

if (!(Test-Path -Path "assets")) {
    New-Item -ItemType Directory -Path "assets" | Out-Null
}

Write-Host "Found $($urls.Count) assets to download."

foreach ($url in $urls) {
    try {
        $filename = $url.Split('/')[-1].Split('?')[0]
        if ($url -match "peachworlds") {
            $safename = $url.Split('/')[-2] + '_' + $filename
        } else {
            $safename = $filename
        }
        $localPath = "assets/$safename"
        
        # Write-Host "Downloading $url"
        Invoke-WebRequest -Uri $url -OutFile $localPath -UserAgent "Mozilla/5.0" -UseBasicParsing
        
        $content = $content.Replace($url, $localPath)
    } catch {
        Write-Host "Failed to download $url"
    }
}

$relativeUrls = @("/social.jpg", "/favicon.ico")
foreach ($rUrl in $relativeUrls) {
    try {
        $url = "https://huge-5qpgs73fuc.peachweb.site$rUrl"
        $filename = $rUrl.TrimStart('/')
        Invoke-WebRequest -Uri $url -OutFile $filename -UserAgent "Mozilla/5.0" -UseBasicParsing
    } catch {}
}

Set-Content -Path "index.html" -Value $content -Encoding UTF8
Write-Host "Done! index.html has been updated with local paths."
