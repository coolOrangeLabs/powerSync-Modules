#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#
# Autodesk Platform Services - Data Management Hubs and Projects


### TODO: This should be a single function with a queryparameter field


# Function to get all hubs. Returns all hub objects.
# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET
function Get-ApsHubs {
    Write-Verbose "Reading ACC Hubs..."
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/project/v1/hubs"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained $($response.data.count) hubs!"
    return $response.data
}


# Function to get all hubs of type 'ACC' or 'BIM 360'. Returns all hub objects of type 'ACC' or 'BIM 360'.
# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET
function Get-ApsAccHubs {
    Write-Verbose "Reading ACC Hubs..."
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/project/v1/hubs?filter[extension.type]=hubs:autodesk.bim360:Account"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained $($response.data.count) hubs!"
    return $response.data
}

# Function to get a single ACC hub. Returns a hub object with the given name or $null.
function Get-ApsAccHub($hubName) {
    $hubs = Get-ApsAccHubs
    $hub = $hubs | Where-Object { $_.attributes.name -eq $hubName -and $_.attributes.extension.type -eq "hubs:autodesk.bim360:Account" } | Select-Object -First 1
    if ($hub) {
        return $hub
    } else {
        return $null
    }
}

# Function to get all hubs of type 'Fusion Team'. Returns all hub objects of type 'Fusion Team'.
# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET
function Get-ApsCoreHubs {
    Write-Verbose "Getting core hubs..."

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/project/v1/hubs?filter[extension.type]=hubs:autodesk.core:Hub"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    return $response.data
}

# Function to get all hubs of type 'Personal Hub'. Returns all hub objects of type 'Personal Hub'.
# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET
function Get-ApsPersonalHubs {
    Write-Host "Reading Personal Hubs..."
    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/project/v1/hubs?filter[extension.type]=hubs:autodesk.a360:PersonalHub"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    return $response.data
}
