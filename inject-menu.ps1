$dir = ".\"

$scriptHtml = @"
<script>
document.addEventListener('DOMContentLoaded', function() {
    if(typeof lucide !== 'undefined') { lucide.createIcons(); }
    var mt = document.getElementById('menuToggle');
    var nl = document.getElementById('navLinks');
    if(mt && nl) {
        // Remove old listeners by cloning
        var new_mt = mt.cloneNode(true);
        mt.parentNode.replaceChild(new_mt, mt);
        new_mt.addEventListener('click', function() {
            nl.classList.toggle('active');
        });
    }
});
</script>
</body>
"@

$files = Get-ChildItem -Path $dir -Filter *.html -Recurse
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    if ($content -notmatch "menuToggle\.addEventListener") {
        $content = $content -replace "</body>", $scriptHtml
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Injected $($file.Name)"
    }
}
