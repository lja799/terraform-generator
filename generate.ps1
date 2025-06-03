
$TemplatePath = "template.yaml"
$ConfigPath = "env-config.json"
$OutputDir = "generated"

# Load template
if (-not (Test-Path $TemplatePath)) {
    Write-Error "Missing template.yaml"
    exit 1
}
$templateContent = Get-Content $TemplatePath -Raw

# Load environment data
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Missing env-config.json"
    exit 1
}
$envConfigs = Get-Content $ConfigPath | ConvertFrom-Json

# Loop through environments and render templates
foreach ($env in $envConfigs.PSObject.Properties.Name) {
    $values = $envConfigs.$env
    $outputContent = $templateContent

    foreach ($kv in $values.PSObject.Properties) {
        $key = $kv.Name
        $value = $kv.Value
        $outputContent = $outputContent -replace "%$key%", $value
    }

    # Create environment folder and write file
    $envFolder = Join-Path $OutputDir $env
    if (-not (Test-Path $envFolder)) {
        New-Item -ItemType Directory -Path $envFolder | Out-Null
    }

    $outputFile = Join-Path $envFolder "main.tf"
    $outputContent | Out-File -FilePath $outputFile -Encoding utf8

    Write-Host "Generated config for $env at $outputFile"
}
