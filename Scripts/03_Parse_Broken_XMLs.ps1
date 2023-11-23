$WorkingFolder = "C:\temp\Alphard_Translation"

# Function to translate Japanese text using the Google Translate API
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

# Function to check if string contains any non-English characters
function ContainsNonEnglishCharacters($string) {
    return $string -match '[^\u0000-\u007F]'  # Matches any character outside the ASCII range
}

# Function to replace Japanese text with English translations
function Replace-JapaneseText($node) {
    if ($node -is [System.Xml.XmlText]) {

    #######################################################
            $japaneseText = $node.InnerText.Trim()
            If (ContainsNonEnglishCharacters($japaneseText) -eq $True){
                #"$japaneseText contains Jap chars"
                $japaneseText = $japaneseText -replace '&','%26'
                $englishText = Translate-JapaneseText -text $japaneseText

                $englishtext = $englishtext.substring(0,1).toupper()+$englishtext.substring(1).tolower() 
                $node.InnerText = $englishText

                write-host "$japanesetext          $englishText" -fo yellow
                Add-Content c:\temp\translation_log.txt -Value "$japanesetext          $englishText" -Encoding UTF8
            }
            Else{
                #"$japaneseText doesn't contain any jap chars"
                $englishtext = $japaneseText
                $node.InnerText = $englishText
            }
    #######################################################
    }
    else {
        foreach ($childNode in $node.ChildNodes) {
            Replace-JapaneseText $childNode
        }
    }
}


# Get all XML files in the folder and its subfolders
$xmlFiles = get-content "$WorkingFolder\XML_Error_log_Pass1.txt"

$counter = 0
$XML_Errors = @()
# Process each XML file
foreach ($xmlFile in $xmlFiles) {
    write-host $xmlFile -fo Green

    $counter++
    write-host "COUNTER: $counter of $($xmlFiles.Count)" -ForegroundColor Cyan
    #start-sleep -seconds 1

    Add-Content c:\temp\translation_log.txt -Value "$($xmlFile)======================================================" -Encoding UTF8
    # Load the XML file
    Try {
        $xml = [xml](Get-Content -Path $xmlFile -Encoding UTF8)
    
        # Find and replace Japanese text in the XML using Google Translate
        Replace-JapaneseText $xml

      #  $modifiedXmlPath = $xmlFile.FullName -replace '\.xml$', '_translated.xml'
      #  $xml.Save($modifiedXmlPath)
    
        $xml.Save($xmlFile)
        }
    Catch {
        $XML_Errors += $xmlfile
        Add-Content "$WorkingFolder\XML_Error_log_Pass3.txt" -Value "$($xmlFile)" -Encoding UTF8
    }
}

