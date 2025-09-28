#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - ACC - Account Admin

# Function to get all users of a given ACC project. Returns an array of user objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projectsprojectId-users-GET/
function Get-ApsAccProjectUsers($project, $queryParameters = $null) {
    Write-Verbose "Getting users..."
    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/projects/$(($project.id -replace '^b\.', ''))/users"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    
    $ret = Get-AllApsAccResults -parameters $parameters 
    Write-Verbose "Obtained $($ret.count) users!"

    return $ret
}

# Function to get a single user of a given ACC project by the given User ID. Returns a user object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projectsprojectId-users-userId-GET/
function Get-ApsAccProjectUser($project, $userId, $queryParameters = $null) {
    Write-Verbose "Finding user with ID $userId"

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/projects/$(($project.id -replace '^b\.', ''))/users/$($userId)"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Found user!"

    return $response.results
}

# Function to add a user to a given ACC project. Returns a user object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-project-Id-users-POST/
# TODO: change the available products if needed
function Add-ApsAccProjectUser($project, $user) {
    Write-Host "Adding Project User..."

    $body = ConvertTo-Json @{
        "email" = $user.email
        "companyId" = $user.companyId
        "roleIds" = @($user.roleIds)
        "products" = @(
            @{
                "key" = "projectAdministration"
                "access" = "administrator"
            },
            @{
                "key" = "designCollaboration"
                "access" = "administrator"
            },
            @{
                "key" = "build"
                "access" = "administrator"
            },
            @{
                "key" = "cost"
                "access" = "administrator"
            },
            @{
                "key" = "modelCoordination"
                "access" = "administrator"
            },
            @{
                "key" = "docs"
                "access" = "administrator"
            }             
        )
    } -Depth 100 -Compress

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/projects/$(($project.id -replace '^b\.', ''))/users"
        "Method" = "Post"
        "ContentType" = "application/json"
        "Headers" = $ApsConnection.Headers
        "Body" = $body
    }
    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "User added!"
    return $response
}

# Function to get a single ACC project by the given Project ID. Returns a project object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projectsprojectId-GET/
function Get-ApsAccProject($projectId) {
    Write-Verbose "Searching for project with ID $projectID..."

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/projects/$(($projectId -replace '^b\.', ''))"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained project!"
    return $response
}

# Function to get all project templates of a given ACC account. Returns an array of project objects classfied as 'template'.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountidprojects-GET/
function Get-ApsAccProjectTemplates($hub) {
    Write-Host "Getting project templates..."

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$(($hub.id -replace '^b\.', ''))/projects?filter[classification]=template&filter[status]=active"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained templates!"
    return $response.results  
}

# Function to add a new project to a given ACC account. Returns a project object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountidprojects-POST/
function Add-ApsAccProject($hub, $name, $number, $type, $templateId) {
    Write-Verbose "Attempting to add project '$name'..."

    $body = ConvertTo-Json @{
        "name" = $name
        "type" = $type
        "jobNumber" = $number
        "template" = @{
            "projectId" = $templateId
            "options" = @{
                "field" = @{
                    "includeCompanies" = $true
                    "includeLocations" = $false
                }
            }
        }
    } -Depth 100 -Compress
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$(($hub.id -replace '^b\.', ''))/projects"
        "Method" = "Post"
        "ContentType" = "application/json"
        "Headers" = $ApsConnection.Headers
        "Body" = $body
    }

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Project '$name' has been successfully created!"
    return $response
}

# Function to get all business units of a given ACC account. Returns an array of business unit objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/business_units_structure-GET/
function Get-ApsAccBusinessUnits($hub) {
    Write-Host "Getting business units..."
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/hq/v1/accounts/$(($hub.id -replace '^b\.', ''))/business_units_structure"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Host "Obtained business units..."
    return $response.results
}
