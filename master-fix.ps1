$projects = @(
    "c:\Users\hsyn_\OneDrive\Masaüstü\ibniSinav2",
    "c:\Users\hsyn_\OneDrive\Masaüstü\ibniSinav3",
    "c:\Users\hsyn_\OneDrive\Masaüstü\ibniSinav4"
)

$cacheBuster = "?v=$([Guid]::NewGuid().ToString().Substring(0,8))"

$cssOverride = @"

/* Master Mobile Form Grid Override */
@media (max-width: 768px) {
    .form-grid, .form-grid-2, div[style*="grid-template-columns"] {
        display: flex !important;
        flex-direction: column !important;
        grid-template-columns: 1fr !important;
    }
    [style*="grid-column: span"], div[style*="grid-column"] {
        grid-column: span 1 !important;
        flex-direction: column !important;
        width: 100% !important;
    }
}
"@

foreach ($proj in $projects) {
    if (Test-Path $proj) {
        Write-Host "Processing $proj"
        
        # 1. Update CSS
        $cssFile = ""
        if (Test-Path "$proj\style.css") {
            $cssFile = "$proj\style.css"
        } elseif (Test-Path "$proj\css\style.css") {
            $cssFile = "$proj\css\style.css"
        }
        
        if ($cssFile) {
            $cssContent = Get-Content $cssFile -Raw -Encoding UTF8
            if ($cssContent -notmatch "Master Mobile Form Grid Override") {
                $cssContent += "`n$cssOverride"
                Set-Content -Path $cssFile -Value $cssContent -Encoding UTF8
                Write-Host " - Updated $cssFile"
            }
        }
        
        # 2. Add Cache Buster to HTML
        $htmlFiles = Get-ChildItem -Path $proj -Filter *.html -Recurse
        foreach ($html in $htmlFiles) {
            $htmlContent = Get-Content $html.FullName -Raw -Encoding UTF8
            
            # Find and replace style.css or css/style.css with versioning
            # Matches href="style.css" or href="css/style.css" or href="style.css?v=..."
            $htmlContent = [regex]::Replace($htmlContent, 'href="(.*?style\.css)(\?v=.*?)?"', "`"href=`"`$1$cacheBuster`"`"")
            
            Set-Content -Path $html.FullName -Value $htmlContent -Encoding UTF8
        }
        Write-Host " - Added cache buster to HTML files"
    }
}
