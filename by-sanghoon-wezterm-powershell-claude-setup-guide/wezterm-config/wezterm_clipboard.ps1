[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
$cb = [System.Windows.Forms.Clipboard]::GetDataObject()

if ($cb) {
    if ($cb.ContainsFileDropList()) {
        Write-Output "__FILES__"
        $files = $cb.GetFileDropList() | ForEach-Object { "`"$_`"" }
        Write-Output ($files -join ' ')
    }
    elseif ($cb.ContainsImage()) {
        $img = $cb.GetImage()
        $p = Join-Path $env:TEMP ("claude_img_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".png")
        $img.Save($p, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "__IMAGE__"
        Write-Output $p
    }
    else {
        Write-Output "__TEXT__"
    }
}
