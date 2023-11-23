function Translate-JapaneseText {
  param (
    [Parameter(Mandatory)]
    [string]$Text,
    [Parameter()]
    [string]$TargetLanguage='en',
    [Parameter()]
    [string]$SourceLanguage="ja"
  )

$Url = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=$($SourceLanguage)&tl=$($TargetLanguage)&dt=t&q=$Text”
$Res = Invoke-RestMethod -Uri $Url -Method Get
$Translation = $Res[0].SyncRoot | foreach { $_[0] }
return $Translation
}

$folderPath = 'C:\SC0902J_XML_RAW'

# Load the HTML files
$htmlFiles = Get-ChildItem -Path $folderPath -Filter "*.htm*" -Recurse -file
#$htmlFiles = Get-ChildItem -path 'C:\temp\SC0902J_XML_Translated\repair\contents\rm000000ccz07yx.xml'

################################################

foreach ($htmlFile in $htmlFiles) {
    write-host $htmlFile.FullName -fo Green

    $html = Get-Content -Path $htmlFile.FullName -Raw -Encoding UTF8

    # Find Japanese content inside HTML tags using regular expression
    $pattern = "[\p{IsHiragana}\p{IsKatakana}\p{IsCJKUnifiedIdeographs}\p{IsCJKSymbolsandPunctuation}\p{IsCJKCompatibility}\p{IsCJKUnifiedIdeographsExtensionA}]+"
    $matches = [regex]::Matches($html, $pattern)

    # Iterate over the matches and prompt the user for string input
    foreach ($match in $matches) {
        $originalContent = $match.Value
        Write-Host "Original Content: $originalContent"
        $newContent = Translate-JapaneseText $originalContent
        $html = $html -replace [regex]::Escape($originalContent), $newContent
    }

    # Save the modified HTML to a new file
    #$modifiedHtmlFilePath = [System.IO.Path]::ChangeExtension($htmlFilePath, "_modified.html")
   # $html | Out-File -FilePath "$($htmlFile.Directory.FullName)\$($htmlFile.Name)_Translated$($htmlFile.Extension)" -Encoding utf8
     $html | Out-File -FilePath "$($htmlFile.FullName)" -Encoding utf8
}
