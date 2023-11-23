$WorkingFolder = "C:\temp\Alphard_Translation"
$XML_Errors = get-content -Path "$WorkingFolder\XML_Error_log_Pass1.txt"

# Read the content of the file
ForEach($XmlErrorFile in $XML_Errors){
    write-host $XmlErrorFile -fo Cyan
    $content = Get-Content -Path $XmlErrorFile

    # Loop through each line
    for ($i = 0; $i -lt $content.Length; $i++) {
        # Check if the line starts with '&' and ends with ';'
        if ($content[$i] -match '^&.*;$') {
            # Prepend "<!-- " and append " -->" to the line
            $content[$i] = "<!-- " + $content[$i] + " -->"
        }
    }

    # Write the modified content back to the file
    $content | Set-Content -Path $XmlErrorFile
}
