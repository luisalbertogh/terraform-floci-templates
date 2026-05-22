[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryName = "app-images",

    [Parameter()]
    [string]$LocalImage = "myimage",

    [Parameter()]
    [string]$LocalTag = "latest",

    [Parameter()]
    [string]$RemoteTag = "latest",

    [Parameter()]
    [string]$Region = "eu-west-1",

    [Parameter()]
    [string]$EndpointUrl = "http://localhost:4566",

    [Parameter()]
    [string]$Profile = ""
)

$ErrorActionPreference = "Stop"

function Invoke-AwsCli {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $baseArgs = @("--endpoint-url", $EndpointUrl, "--region", $Region)

    if (-not [string]::IsNullOrWhiteSpace($Profile)) {
        $baseArgs += @("--profile", $Profile)
    }

    aws @baseArgs @Arguments
}

Write-Host "Resolving repository URI from ECR..." -ForegroundColor Cyan
$repositoryUri = Invoke-AwsCli -Arguments @(
    "ecr", "describe-repositories",
    "--repository-names", $RepositoryName,
    "--query", "repositories[0].repositoryUri",
    "--output", "text"
)

if ([string]::IsNullOrWhiteSpace($repositoryUri) -or $repositoryUri -eq "None") {
    throw "Repository '$RepositoryName' was not found. Run Terraform apply first or check repository name."
}

$repositoryUri = $repositoryUri.Trim()
$registryHost = $repositoryUri.Split("/")[0]

$localRef = "$LocalImage`:$LocalTag"
$remoteRef = "$repositoryUri`:$RemoteTag"

Write-Host "Logging in to registry $registryHost..." -ForegroundColor Cyan
Invoke-AwsCli -Arguments @("ecr", "get-login-password") | docker login --username AWS --password-stdin $registryHost

if ($LASTEXITCODE -ne 0) {
    throw "Docker login failed."
}

Write-Host "Tagging image: $localRef -> $remoteRef" -ForegroundColor Cyan
docker tag $localRef $remoteRef

if ($LASTEXITCODE -ne 0) {
    throw "Docker tag failed. Ensure local image '$localRef' exists."
}

Write-Host "Pushing image: $remoteRef" -ForegroundColor Cyan
docker push $remoteRef

if ($LASTEXITCODE -ne 0) {
    throw "Docker push failed."
}

Write-Host "Verifying image in ECR..." -ForegroundColor Cyan
Invoke-AwsCli -Arguments @(
    "ecr", "describe-images",
    "--repository-name", $RepositoryName,
    "--query", "sort_by(imageDetails,&imagePushedAt)[-5:].{digest:imageDigest,tags:imageTags,pushedAt:imagePushedAt}",
    "--output", "table"
)

Write-Host "Done." -ForegroundColor Green
