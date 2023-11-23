$WorkingFolder = "C:\temp\Alphard_Translation"
$XML_Errors = get-content -Path "$WorkingFolder\XML_Error_log_Pass1.txt"

# Read the content of the file
ForEach($XmlErrorFile in $XML_Errors){
    write-host $XmlErrorFile -fo Cyan
    $filecontent = Get-Content -Path $XmlErrorFile -raw -Encoding UTF8

    $fileContent = $fileContent -replace '<!-- ', '' -replace ' -->', ''

    $filecontent | Set-Content -Path $XmlErrorFile -Encoding UTF8
}
