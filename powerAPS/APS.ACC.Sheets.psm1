#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2025 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Function Gets all version sets within the project with the given projectID
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-GET/
function Get-VersionSets($projectID){
    Write-Verbose "Getting version sets..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$projectID/version-sets"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained version sets!"
    return $response
}

# Function sets a version set by the given name in the project with the given project ID
function Get-VersionSet($projectID, $name){
   Write-Verbose "Getting version set '$name'"
    $vSets = Get-VersionSets -projectID $projectID
    $ret = $vSets.results | Where-Object {$_.name -eq $name} | Select-Object -First 1
    if ($null -eq $ret){
        Write-Verbose "Could not find version set '$name...'"
        return $null
    }
    else{
        Write-Verbose "Found Version Set '$name'"
        return $ret
    }
}


# Function adds a new Version set to sheets under the given name with the given issuance date within the project with the given project ID.
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-POST/
function Add-VersionSet($project, $name, $issuanceDate){
    Write-Verbose "Attempting to add version set '$name'..."
    $body =  ConvertTo-Json @{
        "name" = "$($name)";
        "issuanceDate" = "$($issuanceDate)"
    } -Depth 100 -Compress

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/version-sets"
        "Method"  = "Post"
        "ContentType" = "application/json"
        "Headers" = $ApsConnection.Headers
        "Body" = $body
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Version set '$name' added successfully!"
    return $response
}

#2
function Add-StorageObject($project, $fileName){
    $body =  ConvertTo-Json @{
        "fileName" = "$($fileName)";
       
    } -Depth 100 -Compress
   

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/storage"
        "Method"  = "Post"
        "ContentType" = "application/json"
        "Headers" = $ApsConnection.Headers
        "Body" = $body
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

#3
#Function generates a signed s3 upload url used as an endpoint for posting. Used for uploads ONLY.
function Get-SignedURL($bucketKey, $objectKey){

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/oss/v2/buckets/$bucketKey/objects/$objectKey/signeds3upload"
        "ContentType" = "application/json"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}


#4
function Publish-ToUrl($url, $filePath){

    #$content = Get-content -path $filePath

    $parameters = @{
        "Uri"     = "$url"
        "Method"  = "Put"
        #"Headers" = $ApsConnection.Headers
        "InFile" = $filePath
        "ContentType" = "application/x-www-form-urlencoded"
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

#5
function Get-UploadBucket($bucketKey, $objectKey, $uploadKey){
    $body =  ConvertTo-Json @{
        "uploadKey" = "$($uploadKey)";     
    } -Depth 100 -Compress

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/oss/v2/buckets/$bucketKey/objects/$objectKey/signeds3upload"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "Body"    =  $body
        ContentType = "application/json"
    }    

    $response = Invoke-RestMethod @parameters
    return $response

}

#6
function Publish-Uploads($versionSetId, $project, $uploadedFileNames, $urn){
    $fileObjects = @()
    $uploadedFileNames | ForEach-Object{
        $temp = @{
            "storageType" = "OSS";
            "storageUrn" = $urn;
            "name" = $_
        }
        $fileObjects += $temp
    }

  
    $body =  ConvertTo-Json @{
        "versionSetId" = "$($versionSetId)";
        "files" = $fileObjects    
    } -Depth 100 -Compress
   

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/uploads"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "Body" = $body
        "ContentType" = "application/json"
    }    

    $response = Invoke-RestMethod @parameters
    return $response

}


#7
function Get-UploadStatus($project, $uploadID){
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/uploads/$uploadID"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

#8
function Get-Uploads($project, $uploadID){
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/uploads/$uploadID/review-sheets"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

#11
function Publish-ReviewSheets($project, $uploadID){

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/uploads/$uploadID/review-sheets:publish"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

function Get-ReviewSheets($project, $uploadID){
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/uploads/$uploadID/review-sheets"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

function Get-Sheets($project){
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$(($project.id -replace '^b\.', ''))/sheets"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

# Adds a local file to Sheets
function Add-ToSheets($project, $versionSetName, $issuanceDate, $storageObjectName, $localFileName){

    $projectID = $(($project.id -replace '^b\.', ''))

    $versionSet = Get-VersionSet -projectID $projectID -name $versionSetName
    if ($null -eq $versionSet){
        $versionSet = Add-VersionSet -projectID $projectID -name $versionSetName -issuanceDate $issuanceDate #1
    }
    $versionSetID = $versionSet.Id

    $storageObject = Add-StorageObject -projectID $projectID -fileName $storageObjectName #2
    $keys = $storageObject.urn.substring(27).Split('/')
    $bucketKey = $keys[0]
    $objectKey = $keys[1]

    $signedUrl = Get-SignedURL -bucketKey $bucketKey -objectKey $objectKey #3
    $url = $signedUrl.urls[0]
    $uploadKey = $signedUrl.uploadKey

    Publish-ToUrl -url $url -filePath $localFileName | Out-Null #4 

    Get-UploadBucket -bucketKey $bucketKey -objectKey $objectKey -uploadKey $uploadKey | Out-Null #5
    $storageObjectNameArray = @($storageObjectName)

    $postUploadsResponse = Publish-Uploads -versionSetID $versionSetID -projectID $projectID -urn $storageObject.urn -uploadedFileNames $storageObjectNameArray #6
    $uploadID = $postUploadsResponse.Id 
    return $uploadID;
}

# Numbers sheets with the naming scheme "$prefix$separator$number" EX "prefix 'sheet' separator ' - ' gets "sheet - 1"
function NumberSheetsNumerically($project, $uploadID, $prefix = "", $separator = " - "){
    $counter = 1
    $projectID = $(($project.id -replace '^b\.', ''))
    $uploads = Get-Uploads -projectID $projectID -uploadID $uploadID

    $body = @()
    $uploads.results|
    ForEach-Object {
        $body += @{
            "id" = $_.id
            "number" = "$prefix$separator$counter"
        }
        $counter += 1;
    } 

    $jsonBody = ConvertTo-Json $body -Depth 100 -Compress
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$projectID/uploads/$uploadID/review-sheets"
        "Method"  = "Patch"
        "Headers" = $ApsConnection.Headers
        "Body"    = $jsonBody
        "ContentType" = "application/json"
    }     
    $response = Invoke-RestMethod @parameters
    $response  
}
