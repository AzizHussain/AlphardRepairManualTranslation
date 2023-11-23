    
# Function to open folder browser dialog
Function Select-FolderDialog {

	param([string]$Description="Select a location in which to copy the raw untranslated files:",[string]$RootFolder="Desktop")

	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

	$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
	$objForm.Rootfolder = $RootFolder
	$objForm.Description = $Description
	$Show = $objForm.ShowDialog()
	If ($Show -eq "OK")	{
		Return $objForm.SelectedPath
	} Else {
		Write-Error "Operation cancelled by user."
	}
}

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
    $replacementTable = @{
        'hdd' = 'HDD'
        'usb' = 'USB'
        'avc-lan' = 'AVC-LAN'
        'gnd' = 'GND'
        'Avrcp' = 'AVCRP'
        'mds' = 'MDS'
        'mdlp' = 'MDLP'
        'bluetooth' = 'Bluetooth'
        'gps' = 'GPS'
        'ecu' = 'ECU'
        'mp3' = 'MP3'
        'wma' = 'WMA'
        'iso' = 'ISO'
        'cd-rom' = 'CD-ROM'
        'cd-r' = 'CD-R'
        'cd-rw' = 'CD-RW'
        'mpeg' = 'MPEG'
        'khz' = 'Khz'
        'T T ' = 'T'
        'I I ' = 'I'
        'uv' = 'UV'
        'cd' = 'CD'
        'tx' = 'TX'
        'rx' = 'RX'
        'sst' = 'SST'
    }


    if ($node -is [System.Xml.XmlText]) {

    #######################################################
            $japaneseText = $node.InnerText.Trim()
            If (ContainsNonEnglishCharacters($japaneseText) -eq $True){
                #"$japaneseText contains Jap chars"
                $japaneseText = $japaneseText -replace '&','%26'
                $englishText = Translate-JapaneseText -text $japaneseText
                

                #Manual corrections
                $englishtext = $englishtext.substring(0,1).toupper()+$englishtext.substring(1).tolower() 
                $node.InnerText = $englishText

                ##############################################################################
                # Iterate through each key in the hashtable
                foreach ($key in $replacementTable.Keys) {
                    # Check if the input string contains the key
                    if ($englishText -match $key) {
                        # Replace the key with the corresponding value
                        $englishText = $englishText -replace [regex]::Escape($key), $replacementTable[$key]
                         write-host $englishText -ForegroundColor Magenta # TESTING - to identify where a manual hashtable correction has happened
                    }
                }

                ##############################################################################

                write-host "$japanesetext          $englishText" -fo yellow
                # TODO - Pass working directory from main script rather thah hardcoding
                Add-Content c:\temp\\Alphard_Translation\TranslationFunction_Log.txt -Value "$japanesetext          $englishText" -Encoding UTF8
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


# Folder path containing the XML files to translate
$folderPath = 'C:\SC0902J_XML_RAW'

# Get all XML files in the folder and its subfolders
$xmlFiles = Get-ChildItem -Path "$folderPath" -Filter "*.xml" -Recurse
#$xmlFiles = Get-ChildItem -Path "C:\SC0902J_XML_RAW\repair\contents\rm000000ccz07yx.xml" # TESTING - for individual file

# Create working folder for temporary files
if(!(Test-Path -Path "C:\temp\Alphard_Translation" )){ New-Item -ItemType Directory -Path "C:\temp\Alphard_Translation" -Force ; write-host "Created temporary working folder at C:\temp\Alphard_Translation" -fo White }
    $WorkingFolder = "C:\temp\Alphard_Translation"
$counter = 0
$XML_Errors = @()

# Process each XML file
foreach ($xmlFile in $xmlFiles) {
    write-host $xmlFile.FullName -fo Green

    $counter++
    write-host "COUNTER: $counter of $($xmlFiles.Count)" -ForegroundColor Cyan
    #start-sleep -seconds 2 TESTING - Create a small delay between processing each file

    #Add-Content "$WorkingFolder\translation_log.txt" -Value "$($xmlFile.FullName)" -Encoding UTF8

    # Load the XML file
    Try {
        $xml = [xml](Get-Content -Path $xmlFile.FullName -Encoding UTF8)
    
        #Find and replace Japanese text in the XML using Google Translate
        Replace-JapaneseText $xml

        #$modifiedXmlPath = $xmlFile.FullName -replace '\.xml$', '_translated.xml'
        #$xml.Save($modifiedXmlPath)
    
        #$xml.Save("$($xmlFile.FullName)")
        $xml.Save("$($xmlFile.FullName)") # TESTING - So it doesn't overwrite original raw file
    }
    Catch {
        #$XML_Errors += $xmlfile.fullname
        Add-Content "$WorkingFolder\XML_Error_log_Pass1.txt" -Value "$($xmlFile.FullName)" -Encoding UTF8
    }
}

