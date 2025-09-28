#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - ACC - Issues

# Function to get all issues of a given project. Returns an array of issue objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-GET/
function Get-ApsAccIssues($project) {
    Write-Verbose "Getting issues in project with id $($project.id)..."
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issues"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained issues!"
    return $response.results
}

# Function to get all comments of a given issue. Returns an array of comment objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-comments-GET/
function Get-ApsAccIssueComments($project, $issue) {
    Write-Verbose "Getting issue comments from issue with id $($issue.id) in project with id $($project.id)..."
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issues/$($issue.id)/comments"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained issue comments!"
    return $response.results
}

# Function to add a comment to a given issue. Returns a comment object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-comments-POST/
function Add-ApsAccIssueComments($project, $issue, $commentText) {
    Write-Verbose "Adding issue comment to issue with ID $($issue.id)..."
    $body = ConvertTo-Json @{ "body" = "$($commentText)" } -Depth 100 -Compress
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issues/$($issue.id)/comments"
        "Method" = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Issue comment successfully added!"
    return $response
}

# Function to get all issue types of a given project. Returns an array of issue type objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-types-GET/
function Get-ApsAccIssueTypes($project) {
    Write-Verbose "Getting issue types from project with ID $($project.id)..."

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issue-types?include=subtypes"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained issue types!"
    return $response.results
}

# Function to get all root causes of a given project. Returns an array of root cause objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-root-cause-categories-GET/
function Get-ApsAccRootCauses($project) {
    Write-Verbose "Getting root causes of project with ID $($project.id)"
    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issue-root-cause-categories?include=rootcauses"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained root causes"
    return $response.results
}

# Function to Update an issue state. Returns the updated issue object.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-issueId-PATCH/
function Update-ApsAccIssueState($project, $issue, $status) {
    Write-Verbose "Attempting to update issue with ID $($issue.id)"

    $body = ConvertTo-Json @{"status" = $status} -Compress
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/construction/issues/v1/projects/$(($project.id -replace '^b\.', ''))/issues/$($issue.id)"
        "Method" = "Patch"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }
    $response = Invoke-RestMethod @parameters
    return $response.results
}