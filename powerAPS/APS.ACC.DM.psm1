#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - ACC - Files (Document Management) - Custom Attributes (beta)

# Function to get all custom attribute definitions of a given folder. Returns an array of custom attribute definition objects.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/document-management-custom-attribute-definitions-GET/
function Get-ApsAccCustomAttributeDefinitions($project, $folder) {
    Write-Verbose "Getting custom attribute definitions from folder..."
    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/bim360/docs/v1/projects/$(($project.id -replace '^b\.', ''))/folders/$([System.Web.HttpUtility]::UrlEncode($folder.id))/custom-attribute-definitions"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained custom attribute definitions!"
    return $response.results
}

# Function to get all custom attributes of a given version. Returns an array with one version object with an array property 'customAttributes'.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/document-management-versionsbatch-get-POST/
function Get-ApsAccCustomAttributes($project, $version) {
    # Read Custom Attributes
    Write-Verbose "Getting custom attributes from file..."
    $body = @{
        "urns" = @($version.urn)
    }
    $body = @"
{
    "urns": [
    "$($version.urn)"
    ]
}
"@    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/bim360/docs/v1/projects/$($project.id.TrimStart("b."))/versions:batch-get"
        "Method" = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }
    $response = Invoke-RestMethod @parameters 
    Write-Verbose "Obtained custom attributes from file!"
    return $response.results
}
# Function to update custom attributes of a given version. Returns nothing.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/document-management-custom-attributesbatch-update-POST/
function Update-ApsAccCustomAttributes($project, $version, [HashTable]$properties) {
    Write-Verbose "Attempting to update custom attributes on file..."

    $values = @()
    foreach ($prop in $properties.GetEnumerator()) {
        $value = @{
            "id" = $prop.Name
            "value" = $prop.Value
        }
        $values += $value
    }
    $body = ConvertTo-Json @($values) -Compress
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/bim360/docs/v1/projects/$(($project.id -replace '^b\.', ''))/versions/$([System.Web.HttpUtility]::UrlEncode($version.id))/custom-attributes:batch-update"
        "Method" = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json; charset=utf-8"
        "Body" = $body
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully updated custom attributes!"
    return $response
}


# Autodesk Platform Services - ACC - Files (Document Management) - Permissions (beta)

# Function to add permissions to a given folder for a given user. Returns nothing.
# API documentation: https://aps.autodesk.com/en/docs/acc/v1/reference/http/document-management-projects-project_id-folders-folder_id-permissionsbatch-create-POST/

# TODO: Clean up permissions
function Add-ApsAccFolderPermissions($project, $folder, $subjectUser) {
    Write-Verbose "Attempting to add folder permissions for user with ID $($subjectUser.id)..."
    
    $body = ConvertTo-Json @(@{
        "subjectId" = "$($subjectUser.id)"
        "subjectType" = "USER"
        "actions" = @(
            "VIEW",
            "DOWNLOAD",
            "COLLABORATE",
            "PUBLISH",
            "EDIT"
        )
    }) -Depth 100 -Compress

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/bim360/docs/v1/projects/$(($project.id -replace '^b\.', ''))/folders/$($folder.id)/permissions:batch-create"
        "Method" = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }
    $response = Invoke-RestMethod @parameters
    
    Write-Verbose "Successfully added folder permissions for user with ID $($subjectUser.id) !"
    return $response
}

# Uses uploadUrn to get a bucket and object key, which gets you a download link to call Get-AndSave
function Get-SignedURLDownload ($bucketkey, $objectKey){
    Write-Verbose "Generating signed download URL..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/oss/v2/buckets/$bucketKey/objects/$objectKey/signeds3download"
        "ContentType" = "application/json"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully generated signed download URL!"
    return $response
}


function Add-FileStorageObject($project){

    Write-Verbose "Attempting to create a file storage object for project with ID $($project.id)"

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/data/v1/projects/$(($project.id -replace '^b\.', ''))/storage"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
    
    #https://developer.api.autodesk.com/data/v1/projects/:project_id/storage
}


function Get-ApsFileVersions($project, $file){

    Write-Verbose "Getting file versions for file with ID $($file.ID)..."
    
    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/data/v1/projects/$($project.id)/items/$fileID/versions"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained file versions for file with ID $($file.ID)!"
    return $response
}

function Get-DownloadFromUrl($url, $path){

    Write-Verbose "Attempting to save file from $url to $path..."
    $parameters = @{
        "Uri"     = "$url"
        "Method"  = "Get"
        "OutFile" = $path
    }     
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully downloaded file to $path!"
    $response  
}

function Save-VersionFile($project, $version, $exportPath){

    Write-Verbose "Attempting to save $($version.name) to $exportPath..."
    $export = Export-PDFFile -project $project -versionID $version.urn -fileName $version.name
    Write-Verbose "PDF Export queued in ACC..."
    $exportJob = $null
    do {
        Start-Sleep -Seconds 5
        $exportJob = Get-PdfExportStatus -project $project -export $export
    }
    while ($exportJob.status -eq "processing")

    if ($exportJob.status -eq "successful"){
        Write-Verbose "PDF export Successful! Downloading File $($version.name)"
        try{
        $response = Invoke-RestMethod -Uri $exportJob.result.output.signedurl -OutFile $exportPath
        Write-Verbose "File Successfully downloaded to $exportPath!"
        return $response
        }
        catch {
            Write-Error "Error downloading file $($version.name)"
            $_
        }
    }
    else{
        Write-Error "PDF export failed for file $($version.name)..."
    }
}


# Takes in powerVault version of $file 
function Add-AccFile($project, $accFolder, $file, $apsVersionRefs){
    Write-Verbose "Attempting to upload file $($file.LocalPath) to ACC..."
    $uploadObject = Add-ApsBucketFile $project $accFolder $file.LocalPath
    $foundFile = Get-ApsFolderContents $project $accFolder | Where-Object {$_.type -eq "items" -and $_.attributes.displayName -eq $([System.IO.Path]::GetFileName($file.LocalPath))}
    if (-not $foundFile){
        $version = Add-ApsFirstVersion $project $accFolder $file.LocalPath $uploadObject $apsVersionRefs
    }
    else{
        $version = Add-ApsNextVersion $project $foundFile $file.LocalPath $uploadObject $apsVersionRefs
    }
    Write-Verbose "Version $($version.attributes.versionNumber) of file $($file.LocalPath) posted to ACC!"
    return $version
}

# Takes in windows version of $file.
function Add-AccFileFromLocal($project, $accFolder, $file){
    Write-Verbose "Attempting to upload file $($file.FullName) to ACC..."
    $uploadObject = Add-ApsBucketFile $project $accFolder $file.FullName
    $foundFile = Get-ApsFolderContents $project $accFolder | Where-Object {$_.type -eq "items" -and $_.attributes.displayName -eq $([System.IO.Path]::GetFileName($file.FullName))}
    if (-not $foundFile){
        $version = Add-ApsFirstVersion $project $accFolder $file.FullName $uploadObject $null
    }
    else{
        $version = Add-ApsNextVersion $project $foundFile $file.FullName $uploadObject $null
    }
    Write-Verbose "Version $($version.attributes.versionNumber) of file $($file.FullName) posted to ACC!"
}
