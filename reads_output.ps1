[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArmOutputString,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [bool]$lowerCase
)

Write-Output "Retrieved input: $ArmOutputString"
$armOutputObj = $ArmOutputString | ConvertFrom-Json

$armOutputObj.PSObject.Properties | ForEach-Object {
    $type = ($_.value.type).ToLower()
    $keyname = $_.Name
    $vsoAttribs = @("task.setvariable variable=$keyName")

    if ($type -eq "array") {
        $value = $_.Value.value.name -join ',' ## All array variables will come out as comma-separated strings
    } elseif ($type -eq "securestring") {
        $vsoAttribs += 'isSecret=true'
    } elseif ($type -ne "string") {
        throw "Type '$type' is not supported for '$keyname'"
    } else {
        $value = $_.Value.value
    }

    $attribString = $vsoAttribs -join ';'

    if($lowerCase){
        $value = $($value).ToLower()
    }

    $var = "##vso[$attribString]$value"
 
    ECHO $keyname
    ECHO $value
   
    Write-Output -InputObject $var
}
