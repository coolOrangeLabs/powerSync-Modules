#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - ACC - Relationships

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/relationship-service-v2-get-writable-relationship-domains-GET/
function Get-ApsAccRelationshipEntityTypes() {

    Write-Verbose "Getting relationship entity types..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/bim360/relationship/v2/utility/relationships:writable"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained relationship entity types!"
    return $response
}

# https://aps.autodesk.com/en/docs/bim360/v1/reference/http/relationship-service-v2-search-relationships-GET/
# Get-ApsAccRelationships -project $Project -withTypes @("asset", "submittalItem") -withID $currSubmittal.id
function Get-ApsAccRelationships($project, [string]$withID = $null, [array]$withTypes = $null) {
    Write-Verbose "Getting relationships in project with ID $($project.id)..."
    $relationships = @()
    $continuationToken = $null
    
    $count = 1
    if ($withID){
        Write-Host "USING ID!"
    }

    do {
        $uri = "https://developer.api.autodesk.com/bim360/relationship/v2/containers/$($project.id.TrimStart("b."))/relationships:search"
        $additions = @()

        if ($continuationToken){
            $additions += "continuationToken=$continuationToken"
        }
        if ($withID){
            
            $additions += "id=$withID"
        }
        if ($withTypes){
            $withTypes | ForEach-Object {
                $additions += "type=$_"
                switch ($_.ToLower()){
                 "asset" {$additions += "domain=autodesk-bim360-asset"}
                 "submittalitem" {$additions += "domain=autodesk-construction-submittals"}
                 "rfi" {$additions += "autodesk-bim360-rfi"}
                 "form" {$additions += "autodesk-construction-form"}
                 "documentlineage"{$additions += "autodesk-bim360-documentmanagement"}
                 "markup" {$additions += "autodesk-construction-markup"}
                 "markupdocument" {$additions += "autodesk-construction-markup"}
                 "task" {$additions += "autodesk-construction-schedule"}
                 "location" {$additions += "autodesk-bim360-locations"}
                 "issue" {$additions += "autodesk-bim360-issue "}
                 "budget" {$additions += "autodesk-bim360-cost "}
                 "markupsheethistory" {$additions += "autodesk-construction-markup  "}
                 "activity" {$additions += "autodesk-construction-schedule "}
                 "package" {$additions += "autodesk-construction-filepackages"}
                 "photo" {$additions += "autodesk-construction-photo"}
                 "formtemplate" {$additions += "autodesk-construction-form"}
                 "systemcategory" {$additions += "autodesk-bim360-asset "}
                 "meetingitem" {$additions += "autodesk-bim360-meetingminutes"}
                }
            }
        }

        if ($additions.count -gt 0){
            $adds = "?$($additions -join '&')"
            $uri += $adds
        }

      
        $count++

        $parameters = @{
            "Uri"     = $uri
            "Method"  = "Get"
            "Headers" = $ApsConnection.Headers
        }   

        $response = Invoke-RestMethod @parameters

        $relationships += $response.relationships
        $continuationToken = $response.page.continuationToken
    }
    while ($continuationToken)
    Write-Host "Obtained relationships!"
    return $relationships
}

# https://aps.autodesk.com/en/docs/bim360/v1/reference/http/relationship-service-v2-add-relationships-PUT/
function Add-ApsAccRelationship($project, $version1, $version2) {
    Write-Verbose "Attempting to add relationship between entities..."
    $body = @"
[
    {
        "entities": [
            {
                "domain": "autodesk-bim360-documentmanagement",
                "type": "fileversion",
                "id": "$($version1.id)",
                "createdOn": "$($version1.attributes.createTime)"
            },
            {
                "domain": "autodesk-bim360-documentmanagement",
                "type": "fileversion",
                "id": "$($version2.id)",
                "createdOn": "$($version2.attributes.createTime)"
            }
        ]
    }
]
"@

    $parameters = @{
        "Uri"         = "https://developer.api.autodesk.com/bim360/relationship/v2/containers/$($project.id.TrimStart("b."))/relationships"
        "Method"      = "Put"
        "ContentType" = "application/json"
        "Body"        = $body
        "Headers"     = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Relationship successfully added"
    return $response
}

# https://aps.autodesk.com/en/docs/bim360/v1/reference/http/relationship-service-v2-delete-relationships-POST/
function Remove-ApsAccRelationships($project, [array]$relationshipIds) {

    Write-Verbose "Attempting to remove $($relationshipIds.count) relationships from project with id $($project.id)"
    $body = @"
[
    "$($relationshipIds -join '","')"
]
"@

    $parameters = @{
        "Uri"         = "https://developer.api.autodesk.com/bim360/relationship/v2/containers/$($project.id.TrimStart("b."))/relationships:delete"
        "Method"      = "Post"
        "ContentType" = "application/json"
        "Body"        = $body        
        "Headers"     = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Relationships successfully removed"
    return $response
}
