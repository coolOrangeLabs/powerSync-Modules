#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - ACC - Assets

# Function to get all asset categories of a given ACC project. Returns an array of category objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-categories-GET/

function Get-ApsAccAssetCategories ($project, $queryParameters = $null) {
    Write-Verbose "Reading ACC Asset Categories..."
    $uri = Add-ToUri -uri "https://developer.api.autodesk.com/construction/assets/v1/projects/$(($project.id -replace '^b\.', ''))/categories" -queryParameters $queryParameters

    $parameters = @{
        "Uri"     = $uri
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $ret = Get-AllApsAccResults -parameters $parameters
    Write-Verbose "Obtained $($ret.count) asset categories!"
    return $ret
}

# Function to get all asset status sets of a given ACC project. Returns an array of asset status set objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-status-step-sets-GET/
function Get-ApsAccAssetStatusSets($project, $queryParameters = $null) {
    Write-Host "Reading ACC Asset Status Sets..."

    $uri = Add-ToUri -uri "https://developer.api.autodesk.com/construction/assets/v1/projects/$(($project.id -replace '^b\.', ''))/status-step-sets" -queryParameters $queryParameters
    $parameters = @{
        "Uri"     = $uri
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }

   
    $ret = Get-AllApsAccResults -parameters $parameters
    Write-verbose "$($ret) status sets found!"
    return $ret
}

# Function to get all assets of a given ACC project. Returns an array of asset objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-assets-batch-get-v2-POST/
function Get-ApsAccAssetsByIds($project, [array]$ids, $queryParameters = $null) {
    Write-Verbose "Reading ACC Assets..."

    $uri = Add-ToUri -uri "https://developer.api.autodesk.com/construction/assets/v2/projects/$(($project.id -replace '^b\.', ''))/assets:batch-get" -queryParameters $queryParameters
    $body = ConvertTo-Json @{"ids" = @($ids)} -Compress
    $parameters = @{
        "Uri"     = $uri
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }
    
    $ret = Get-AllApsAccResults -parameters $parameters
    Write-Verbose "Found $($ret.count) assets for $($ids.count) ids!"

    return $ret
}

# Function to get all assets of a given ACC project. Returns an array of asset objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-assets-v2-GET/
function Get-ApsAccAssets($project, $queryParameters = $null) {
    Write-Verbose "Reading ACC Assets..."
    $uri = Add-ToUri -uri "https://developer.api.autodesk.com/construction/assets/v2/projects/$(($project.id -replace '^b\.', ''))/assets" -extraParameters $queryParameters 
    $parameters = @{
        "Uri"     = $uri
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $ret = Get-AllApsAccResults -parameters $parameters 
    Write-Verbose "$($ret.count) assets found!"
    return $ret
}


# Function to update the status of a given ACC asset
# $patchEntities = key:value pairs where the key is the assetID of what asset to revise and the value is a hashtable of fields and their new values.
# Returns a set of key:value pairs. The key is the asset ID of the asset that was revised. The value is the fully revised asset.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-assets-batch-patch-PATCH-v2/
function Update-ApsAccAssetsByIDs($project, [hashtable] $patchEntities) {

    Write-Host "Updating ACC Asset Status..."
    
    $body = ConvertTo-Json $patchEntities -Depth 100 -Compress
    $parameters = @{
        "Uri"         = "https://developer.api.autodesk.com/construction/assets/v2/projects/$(($project.id -replace '^b\.', ''))/assets:batch-patch"
        "Method"      = "Patch"
        "Headers"     = $ApsConnection.Headers        
        "ContentType" = "application/json"
        "Body"        = $body        
    }

    $response = Invoke-RestMethod @parameters
    return $response
}


#API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-asset-statuses-GET/
function Get-ApsAssetStatuses($project, $queryParameters = $null){

    Write-Verbose "Getting ACC Asset Statuses"
    $uri = Add-ToUri -uri "https://developer.api.autodesk.com/construction/assets/v1/projects/$(($project.id -replace '^b\.', ''))/asset-statuses" -queryParameters $queryParameters
    $parameters = @{
        "Uri"     = $uri
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $ret = Get-AllApsAccResults -parameters $parameters
    Write-Verbose "Obtained $($ret.count) asset statuses"
    return $ret
}