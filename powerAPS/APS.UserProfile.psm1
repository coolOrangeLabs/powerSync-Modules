#==============================================================================#
# (c) 2024 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

# Autodesk Platform Services - User Profile

# Function to get the user information. Returns the user object.
# API documentation: https://aps.autodesk.com/en/docs/profile/v1/reference/profile/oidcuserinfo/
function Get-ApsUserInfo {
    Write-Verbose "Getting user info..."
    $response = Invoke-RestMethod -Uri "https://api.userprofile.autodesk.com/userinfo" -Method Get -Headers $ApsConnection.Headers
    Write-Verbose "User info obtained"
    return $response
}


function Get-ApsAccMe($project){
    Write-Verbose "Getting this user..."
    $parameters = @{
        "Uri" = " https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/users/me"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained this user!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-GET/
function Get-ApsAccUsers($project){
    Write-Verbose "Getting users..."
    $users = @()
    $nextUrl = $null
    do {
        $parameters = @{
            "Uri" = " https://developer.api.autodesk.com/construction/admin/v1/projects/$(($project.id -replace '^b\.', ''))/users"
            "Method" = "Get"
            "Headers" = $ApsConnection.Headers
        }
        $response = Invoke-RestMethod @parameters
        $users += $response.results
        $nextUrl = $response.nextUrl

    }
    while ($null -ne $nextUrl)
    Write-Verbose "Obtained $($users.count) users"
    return $users
}

