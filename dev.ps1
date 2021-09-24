param([Parameter(Mandatory=$true)]$ResourceGroup, [Parameter(Mandatory=$true)]$Location)

$account = az ad signed-in-user show --query objectId -o json | ConvertFrom-Json

$template = Join-Path $PSScriptRoot .\Infrastructure\ResourceGroup.bicep
$output = az deployment sub create --name $ResourceGroup --template-file $template --location $Location -o json -p identity=$account | ConvertFrom-Json

dotnet user-secrets init
foreach ($o in $output.properties.outputs.psobject.properties)
{
    dotnet user-secrets set $o.name.Replace("__", ":") $o.value.value
}

