<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER websiteName
    The name of the Azure Website to deploy to.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(

 #[Parameter(Mandatory=$True)]
 #[string]
 #$resourceGroupName,

 [Parameter(Mandatory=$True)]
 [string]
 $websiteName,

  [Parameter(Mandatory=$True)]
 [string]
 $mongoConnString,
  
  [Parameter(Mandatory=$True)]
 [string]
 $APISecret,

 [string]
 $templateFilePath = "nightscouttemplate.json",

 [string]
 $parametersFilePath = "nightscoutsiteparameters.json"
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -Confirm:$false;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# Validate that the website name doesn't already exist.
if (Test-AzureName -Website $websiteName) {
    Write-Error "The website $websiteName already exists in Azure.  Please choose another name and try again."
    
}

# Validate that the website name doesn't already exist.
if ($APISecret.Length -lt 12) {
    Write-Error "Your API Secret is less than 12 characters, please try with a longer one."
    
}

$resourceGroupName = $websiteName + "-NSResourceGrp"


# sign in
Write-Host "Logging in...";
Login-AzureRmAccount

# Get subscription
(Get-AzureRmSubscription | Out-GridView -Title "Select the Azure subscription that you want to use ..." -PassThru) | Select-AzureRmSubscription

# Get location
$resourceGroupLocation = (Get-AzureRmLocation | Select DisplayName | Out-GridView -Title "Select the Azure location that you want to deploy to ..." -PassThru).DisplayName

# Register RPs
$resourceProviders = @("microsoft.insights","microsoft.web");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider) -Force;
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
Write-Host "NOTE: This will take a bit of time, and there is no indication of progress!";

$params = @{site_name=$websiteName;region=$resourceGroupLocation;connectionString=$mongoConnString;aPISecret=$APISecret}
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateParameterObject $params -TemplateFile $templateFilePath;
